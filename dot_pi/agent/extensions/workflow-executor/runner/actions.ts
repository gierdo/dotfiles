import type { DatabaseSync } from "node:sqlite";
import { pauseRun, getRun } from "./db.ts";

export interface ExternalActionRecord {
  id: number;
  run_id: string;
  action: string;
  payload: string | null;
  status: "intent" | "confirmed";
  result: string | null;
  created_at: string;
  updated_at: string;
}

export function recordActionIntent(
  db: DatabaseSync,
  runId: string,
  actionName: string,
  payload?: unknown
): number {
  const stmt = db.prepare(`
    INSERT INTO external_actions (run_id, action, payload, status)
    VALUES (?, ?, ?, 'intent')
  `);
  const res = stmt.run(runId, actionName, payload ? JSON.stringify(payload) : null);
  return Number(res.lastInsertRowid);
}

export function recordActionConfirmed(
  db: DatabaseSync,
  actionId: number,
  result?: unknown
): void {
  db.prepare(`
    UPDATE external_actions
    SET status = 'confirmed', result = ?, updated_at = datetime('now')
    WHERE id = ?
  `).run(result ? JSON.stringify(result) : null, actionId);
}

export function getPendingAction(db: DatabaseSync, runId: string): ExternalActionRecord | null {
  const row = db.prepare(`
    SELECT * FROM external_actions
    WHERE run_id = ? AND status = 'intent'
    ORDER BY id DESC LIMIT 1
  `).get(runId) as ExternalActionRecord | undefined;
  return row ?? null;
}

export function reconcileAction(
  db: DatabaseSync,
  actionId: number,
  resolution: "confirmed" | "aborted",
  result?: unknown
): void {
  db.prepare(`
    UPDATE external_actions
    SET status = ?, result = ?, updated_at = datetime('now')
    WHERE id = ?
  `).run(resolution, result ? JSON.stringify(result) : null, actionId);
}

export function checkAndReconcileOnResume(
  db: DatabaseSync,
  runId: string
): { requiresReconciliation: boolean; pendingAction: ExternalActionRecord | null } {
  const pending = getPendingAction(db, runId);
  if (pending) {
    const run = getRun(db, runId);
    if (run && run.status !== "paused") {
      pauseRun(
        db,
        runId,
        run.revision,
        `Unconfirmed external action #${pending.id} ('${pending.action}') requires user reconciliation`
      );
    }
    return { requiresReconciliation: true, pendingAction: pending };
  }
  return { requiresReconciliation: false, pendingAction: null };
}
