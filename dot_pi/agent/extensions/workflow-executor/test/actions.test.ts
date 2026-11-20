import test from "node:test";
import assert from "node:assert/strict";
import { initDatabase, createRun, getRun } from "../runner/db.ts";
import {
  recordActionIntent,
  recordActionConfirmed,
  getPendingAction,
  checkAndReconcileOnResume,
  reconcileAction,
} from "../runner/actions.ts";

test("two-phase external action records intent and confirmation", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-act-1",
    task: "t",
    workflow: "wf",
    initialState: "init",
    definitionFingerprint: "fp",
  });

  const actionId = recordActionIntent(db, "run-act-1", "git_push", { branch: "main" });
  assert.ok(actionId > 0);

  const pending = getPendingAction(db, "run-act-1");
  assert.ok(pending);
  assert.equal(pending.id, actionId);
  assert.equal(pending.status, "intent");

  recordActionConfirmed(db, actionId, { commit: "abc1234" });
  const noPending = getPendingAction(db, "run-act-1");
  assert.equal(noPending, null);
});

test("unresolved external action halts resume for explicit user reconciliation (ISC 8)", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-act-2",
    task: "t",
    workflow: "wf",
    initialState: "init",
    definitionFingerprint: "fp",
  });

  // Action intent recorded, then crash / interruption before confirmation
  const actionId = recordActionIntent(db, "run-act-2", "create_pull_request", { title: "feat" });

  // On resume, checkAndReconcileOnResume blocks run from resuming automatically
  const check = checkAndReconcileOnResume(db, "run-act-2");
  assert.equal(check.requiresReconciliation, true);
  assert.equal(check.pendingAction?.id, actionId);

  const run = getRun(db, "run-act-2");
  assert.equal(run?.status, "paused");
  assert.ok(run?.pause_reason?.includes("requires user reconciliation"));

  // After user reconciles:
  reconcileAction(db, actionId, "confirmed", { pr_number: 42 });
  const check2 = checkAndReconcileOnResume(db, "run-act-2");
  assert.equal(check2.requiresReconciliation, false);
});
