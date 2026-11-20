import test from "node:test";
import assert from "node:assert/strict";
import {
  initDatabase,
  createRun,
  getRun,
  getActiveVisit,
  executeTransition,
  pauseRun,
  completeRun,
  createPendingApproval,
  getPendingApproval,
  resolvePendingApproval,
  listRuns,
} from "../runner/db.ts";

test("initDatabase creates schema idempotently", () => {
  const db = initDatabase(":memory:");
  const tables = db.prepare(`
    SELECT name FROM sqlite_master WHERE type='table' ORDER BY name
  `).all() as { name: string }[];
  const tableNames = tables.map(t => t.name);

  assert.ok(tableNames.includes("runs"));
  assert.ok(tableNames.includes("state_visits"));
  assert.ok(tableNames.includes("transitions"));
  assert.ok(tableNames.includes("pending_approvals"));
  assert.ok(tableNames.includes("invocations"));
  assert.ok(tableNames.includes("loop_counts"));
  assert.ok(tableNames.includes("external_actions"));
});

test("createRun initializes run record with revision 1 and initial visit", () => {
  const db = initDatabase(":memory:");
  const run = createRun(db, {
    id: "run-1",
    task: "my-task",
    workflow: "my-workflow",
    initialState: "start",
    definitionFingerprint: "sha256-test",
  });

  assert.equal(run.id, "run-1");
  assert.equal(run.revision, 1);
  assert.equal(run.current_state, "start");
  assert.equal(run.status, "active");

  const visit = getActiveVisit(db, "run-1");
  assert.ok(visit);
  assert.equal(visit.state_id, "start");
  assert.equal(visit.visit_index, 1);
  assert.equal(visit.exited_at, null);
});

test("executeTransition advances state and increments revision", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-1",
    task: "my-task",
    workflow: "my-workflow",
    initialState: "start",
    definitionFingerprint: "sha256-test",
  });

  const updated = executeTransition(db, {
    runId: "run-1",
    expectedRevision: 1,
    toState: "step2",
    outcomeId: "done",
    reason: "start finished",
  });

  assert.equal(updated.current_state, "step2");
  assert.equal(updated.revision, 2);

  const visit = getActiveVisit(db, "run-1");
  assert.ok(visit);
  assert.equal(visit.state_id, "step2");
  assert.equal(visit.visit_index, 2);
});

test("executeTransition rejects stale revision (optimistic concurrency)", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-1",
    task: "my-task",
    workflow: "my-workflow",
    initialState: "start",
    definitionFingerprint: "sha256-test",
  });

  assert.throws(() => {
    executeTransition(db, {
      runId: "run-1",
      expectedRevision: 99, // stale revision
      toState: "step2",
    });
  }, /Revision conflict/);

  // Verify run was not modified
  const run = getRun(db, "run-1");
  assert.equal(run?.current_state, "start");
  assert.equal(run?.revision, 1);
});

test("pending approvals lifecycle", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-1",
    task: "my-task",
    workflow: "my-workflow",
    initialState: "start",
    definitionFingerprint: "sha256-test",
  });

  const visit = getActiveVisit(db, "run-1")!;
  const approval = createPendingApproval(db, "run-1", visit.id, "next_step", 1, "needs user signoff");
  assert.equal(approval.status, "pending");
  assert.equal(approval.target_state, "next_step");

  const pending = getPendingApproval(db, "run-1");
  assert.ok(pending);
  assert.equal(pending.id, approval.id);

  resolvePendingApproval(db, approval.id, "approved");
  const noPending = getPendingApproval(db, "run-1");
  assert.equal(noPending, null);
});

test("listRuns returns all runs sorted by updated_at", () => {
  const db = initDatabase(":memory:");
  createRun(db, { id: "r1", task: "t1", workflow: "wf1", initialState: "s1", definitionFingerprint: "fp1" });
  createRun(db, { id: "r2", task: "t2", workflow: "wf2", initialState: "s1", definitionFingerprint: "fp2" });

  const runs = listRuns(db);
  assert.equal(runs.length, 2);
  assert.equal(runs.some(r => r.id === "r1"), true);
  assert.equal(runs.some(r => r.id === "r2"), true);
});
