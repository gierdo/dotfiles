import { DatabaseSync } from "node:sqlite";
import { mkdirSync } from "node:fs";
import { dirname } from "node:path";
import type { RunRecord, StateVisitRecord } from "./types.ts";

export interface CreateRunParams {
  id: string;
  task: string;
  workflow: string;
  initialState: string;
  definitionFingerprint: string;
}

export interface TransitionParams {
  runId: string;
  expectedRevision: number;
  toState: string;
  outcomeId?: string;
  reason?: string;
}

export interface PendingApprovalRecord {
  id: number;
  run_id: string;
  state_visit_id: number;
  target_state: string;
  reason?: string;
  created_revision: number;
  status: "pending" | "approved" | "rejected";
  created_at: string;
  resolved_at?: string;
}

export function initDatabase(dbPath: string): DatabaseSync {
  if (dbPath !== ":memory:") {
    mkdirSync(dirname(dbPath), { recursive: true });
  }

  const db = new DatabaseSync(dbPath);
  db.exec("PRAGMA foreign_keys = ON;");
  if (dbPath !== ":memory:") {
    db.exec("PRAGMA journal_mode = WAL;");
  }

  db.exec(`
    CREATE TABLE IF NOT EXISTS runs (
      id TEXT PRIMARY KEY,
      task TEXT NOT NULL,
      workflow TEXT NOT NULL,
      current_state TEXT NOT NULL,
      revision INTEGER NOT NULL DEFAULT 1,
      definition_fingerprint TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active', -- 'active', 'paused', 'completed', 'aborted'
      pause_reason TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS state_visits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id TEXT NOT NULL REFERENCES runs(id),
      state_id TEXT NOT NULL,
      visit_index INTEGER NOT NULL,
      entered_at TEXT NOT NULL DEFAULT (datetime('now')),
      exited_at TEXT
    );

    CREATE TABLE IF NOT EXISTS transitions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id TEXT NOT NULL REFERENCES runs(id),
      from_state TEXT NOT NULL,
      to_state TEXT NOT NULL,
      outcome_id TEXT,
      reason TEXT,
      revision INTEGER NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS pending_approvals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id TEXT NOT NULL REFERENCES runs(id),
      state_visit_id INTEGER NOT NULL REFERENCES state_visits(id),
      target_state TEXT NOT NULL,
      reason TEXT,
      created_revision INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      resolved_at TEXT
    );

    CREATE TABLE IF NOT EXISTS invocations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      parent_run_id TEXT NOT NULL REFERENCES runs(id),
      invocation_id TEXT NOT NULL UNIQUE,
      child_workflow TEXT NOT NULL,
      entry_override TEXT,
      status TEXT NOT NULL DEFAULT 'active', -- 'active', 'completed', 'aborted'
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      finished_at TEXT
    );

    CREATE TABLE IF NOT EXISTS loop_counts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id TEXT NOT NULL REFERENCES runs(id),
      transition_id TEXT NOT NULL,
      count INTEGER NOT NULL DEFAULT 0,
      UNIQUE(run_id, transition_id)
    );

    CREATE TABLE IF NOT EXISTS external_actions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      run_id TEXT NOT NULL REFERENCES runs(id),
      action TEXT NOT NULL,
      payload TEXT,
      status TEXT NOT NULL DEFAULT 'intent', -- 'intent', 'confirmed'
      result TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);

  return db;
}

export function createRun(db: DatabaseSync, params: CreateRunParams): RunRecord {
  db.exec("BEGIN IMMEDIATE");
  try {
    const existing = db.prepare("SELECT * FROM runs WHERE id = ?").get(params.id) as RunRecord | undefined;
    if (existing) {
      throw new Error(`Run '${params.id}' already exists`);
    }

    db.prepare(`
      INSERT INTO runs (id, task, workflow, current_state, revision, definition_fingerprint, status)
      VALUES (?, ?, ?, ?, 1, ?, 'active')
    `).run(
      params.id,
      params.task,
      params.workflow,
      params.initialState,
      params.definitionFingerprint
    );

    db.prepare(`
      INSERT INTO state_visits (run_id, state_id, visit_index)
      VALUES (?, ?, 1)
    `).run(params.id, params.initialState);

    db.exec("COMMIT");
  } catch (err) {
    db.exec("ROLLBACK");
    throw err;
  }

  return getRun(db, params.id)!;
}

export function getRun(db: DatabaseSync, runId: string): RunRecord | null {
  const row = db.prepare("SELECT * FROM runs WHERE id = ?").get(runId) as RunRecord | undefined;
  return row ?? null;
}

export function listRuns(db: DatabaseSync, status?: RunStatus): RunRecord[] {
  if (status) {
    return db.prepare(`
      SELECT * FROM runs WHERE status = ? ORDER BY updated_at DESC
    `).all(status) as unknown as RunRecord[];
  }
  return db.prepare(`
    SELECT * FROM runs ORDER BY updated_at DESC
  `).all() as unknown as RunRecord[];
}

export function getActiveVisit(db: DatabaseSync, runId: string): StateVisitRecord | null {
  const row = db.prepare(`
    SELECT * FROM state_visits
    WHERE run_id = ? AND exited_at IS NULL
    ORDER BY id DESC LIMIT 1
  `).get(runId) as StateVisitRecord | undefined;
  return row ?? null;
}

export function executeTransition(db: DatabaseSync, params: TransitionParams): RunRecord {
  db.exec("BEGIN IMMEDIATE");
  try {
    const run = db.prepare("SELECT * FROM runs WHERE id = ?").get(params.runId) as RunRecord | undefined;
    if (!run) {
      throw new Error(`Run '${params.runId}' not found`);
    }
    if (run.revision !== params.expectedRevision) {
      throw new Error(`Revision conflict: expected ${params.expectedRevision}, but current revision is ${run.revision}`);
    }

    const activeVisit = db.prepare(`
      SELECT * FROM state_visits WHERE run_id = ? AND exited_at IS NULL ORDER BY id DESC LIMIT 1
    `).get(params.runId) as StateVisitRecord | undefined;

    if (activeVisit) {
      db.prepare("UPDATE state_visits SET exited_at = datetime('now') WHERE id = ?").run(activeVisit.id);
    }

    const nextIndex = (activeVisit?.visit_index ?? 0) + 1;
    db.prepare(`
      INSERT INTO state_visits (run_id, state_id, visit_index)
      VALUES (?, ?, ?)
    `).run(params.runId, params.toState, nextIndex);

    db.prepare(`
      INSERT INTO transitions (run_id, from_state, to_state, outcome_id, reason, revision)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      params.runId,
      run.current_state,
      params.toState,
      params.outcomeId ?? null,
      params.reason ?? null,
      run.revision
    );

    const nextRevision = run.revision + 1;
    db.prepare(`
      UPDATE runs
      SET current_state = ?, revision = ?, pause_reason = NULL, status = 'active', updated_at = datetime('now')
      WHERE id = ?
    `).run(params.toState, nextRevision, params.runId);

    db.exec("COMMIT");
  } catch (err) {
    db.exec("ROLLBACK");
    throw err;
  }

  return getRun(db, params.runId)!;
}

export function pauseRun(db: DatabaseSync, runId: string, expectedRevision: number, reason: string): RunRecord {
  db.exec("BEGIN IMMEDIATE");
  try {
    const run = db.prepare("SELECT * FROM runs WHERE id = ?").get(runId) as RunRecord | undefined;
    if (!run) throw new Error(`Run '${runId}' not found`);
    if (run.revision !== expectedRevision) {
      throw new Error(`Revision conflict: expected ${expectedRevision}, current is ${run.revision}`);
    }

    db.prepare(`
      UPDATE runs
      SET status = 'paused', pause_reason = ?, updated_at = datetime('now')
      WHERE id = ?
    `).run(reason, runId);

    db.exec("COMMIT");
  } catch (err) {
    db.exec("ROLLBACK");
    throw err;
  }

  return getRun(db, runId)!;
}

export function completeRun(db: DatabaseSync, runId: string, expectedRevision: number, status: "completed" | "aborted"): RunRecord {
  db.exec("BEGIN IMMEDIATE");
  try {
    const run = db.prepare("SELECT * FROM runs WHERE id = ?").get(runId) as RunRecord | undefined;
    if (!run) throw new Error(`Run '${runId}' not found`);
    if (run.revision !== expectedRevision) {
      throw new Error(`Revision conflict: expected ${expectedRevision}, current is ${run.revision}`);
    }

    const activeVisit = db.prepare(`
      SELECT * FROM state_visits WHERE run_id = ? AND exited_at IS NULL ORDER BY id DESC LIMIT 1
    `).get(runId) as StateVisitRecord | undefined;
    if (activeVisit) {
      db.prepare("UPDATE state_visits SET exited_at = datetime('now') WHERE id = ?").run(activeVisit.id);
    }

    db.prepare(`
      UPDATE runs
      SET status = ?, updated_at = datetime('now')
      WHERE id = ?
    `).run(status, runId);

    db.exec("COMMIT");
  } catch (err) {
    db.exec("ROLLBACK");
    throw err;
  }

  return getRun(db, runId)!;
}

export function createPendingApproval(
  db: DatabaseSync,
  runId: string,
  stateVisitId: number,
  targetState: string,
  createdRevision: number,
  reason?: string
): PendingApprovalRecord {
  const existing = getPendingApproval(db, runId);
  if (existing && existing.state_visit_id === stateVisitId && existing.created_revision === createdRevision) {
    return existing;
  }

  const stmt = db.prepare(`
    INSERT INTO pending_approvals (run_id, state_visit_id, target_state, reason, created_revision, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
  `);
  const res = stmt.run(runId, stateVisitId, targetState, reason ?? null, createdRevision);
  const id = Number(res.lastInsertRowid);
  return db.prepare("SELECT * FROM pending_approvals WHERE id = ?").get(id) as PendingApprovalRecord;
}

export function getPendingApproval(db: DatabaseSync, runId: string): PendingApprovalRecord | null {
  const row = db.prepare(`
    SELECT * FROM pending_approvals
    WHERE run_id = ? AND status = 'pending'
    ORDER BY id DESC LIMIT 1
  `).get(runId) as PendingApprovalRecord | undefined;
  return row ?? null;
}

export function resolvePendingApproval(
  db: DatabaseSync,
  approvalId: number,
  status: "approved" | "rejected"
): void {
  db.prepare(`
    UPDATE pending_approvals
    SET status = ?, resolved_at = datetime('now')
    WHERE id = ?
  `).run(status, approvalId);
}
