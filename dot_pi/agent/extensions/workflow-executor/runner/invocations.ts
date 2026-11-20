import type { DatabaseSync } from "node:sqlite";
import { pauseRun, getRun } from "./db.ts";

export interface InvocationRecord {
  id: number;
  parent_run_id: string;
  invocation_id: string;
  child_workflow: string;
  entry_override?: string;
  status: "active" | "completed" | "aborted";
  created_at: string;
  finished_at?: string;
}

export function getLoopCount(db: DatabaseSync, runId: string, transitionId: string): number {
  const row = db.prepare(`
    SELECT count FROM loop_counts WHERE run_id = ? AND transition_id = ?
  `).get(runId, transitionId) as { count: number } | undefined;
  return row?.count ?? 0;
}

export function checkAndIncrementLoop(
  db: DatabaseSync,
  runId: string,
  transitionId: string,
  maxRetries = 2
): { allowed: boolean; count: number } {
  const current = getLoopCount(db, runId, transitionId);
  if (current >= maxRetries) {
    const run = getRun(db, runId);
    if (run) {
      pauseRun(
        db,
        runId,
        run.revision,
        `Loop thrash guard: transition '${transitionId}' reached retry limit of ${maxRetries}`
      );
    }
    return { allowed: false, count: current };
  }

  const nextCount = current + 1;
  db.prepare(`
    INSERT INTO loop_counts (run_id, transition_id, count)
    VALUES (?, ?, ?)
    ON CONFLICT(run_id, transition_id) DO UPDATE SET count = excluded.count
  `).run(runId, transitionId, nextCount);

  return { allowed: true, count: nextCount };
}

export function resetLoopCount(db: DatabaseSync, runId: string, transitionId: string): void {
  db.prepare("DELETE FROM loop_counts WHERE run_id = ? AND transition_id = ?").run(runId, transitionId);
}

export function createChildInvocation(
  db: DatabaseSync,
  parentRunId: string,
  childWorkflow: string,
  entryOverride?: string
): InvocationRecord {
  const invocationId = `inv_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
  db.prepare(`
    INSERT INTO invocations (parent_run_id, invocation_id, child_workflow, entry_override, status)
    VALUES (?, ?, ?, ?, 'active')
  `).run(parentRunId, invocationId, childWorkflow, entryOverride ?? null);

  return db.prepare("SELECT * FROM invocations WHERE invocation_id = ?").get(invocationId) as InvocationRecord;
}

export function getActiveInvocation(db: DatabaseSync, parentRunId: string): InvocationRecord | null {
  const row = db.prepare(`
    SELECT * FROM invocations
    WHERE parent_run_id = ? AND status = 'active'
    ORDER BY id DESC LIMIT 1
  `).get(parentRunId) as InvocationRecord | undefined;
  return row ?? null;
}

export function completeChildInvocation(
  db: DatabaseSync,
  invocationId: string,
  outcome: "completed" | "aborted"
): void {
  db.prepare(`
    UPDATE invocations
    SET status = ?, finished_at = datetime('now')
    WHERE invocation_id = ?
  `).run(outcome, invocationId);
}
