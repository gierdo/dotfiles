import test from "node:test";
import assert from "node:assert/strict";
import {
  initDatabase,
  getRun,
  getPendingApproval,
  startWorkflowRun,
  resumeWorkflowRun,
  submitOutcome,
  confirmPendingApproval,
  checkAndIncrementLoop,
  createChildInvocation,
  getActiveInvocation,
  completeChildInvocation,
  recordActionIntent,
  checkAndReconcileOnResume,
  reconcileAction,
  validateDefinition,
  type WorkflowDefinition,
} from "../runner/index.ts";

test("ISC 1: runner rejects an invalid definition before a run starts", () => {
  const invalidDef: WorkflowDefinition = {
    name: "bad-def",
    initial: "missing_state",
    states: {
      step1: { transitions: [{ to: "nowhere" }] }
    }
  };
  const val = validateDefinition(invalidDef);
  assert.equal(val.valid, false);

  const db = initDatabase(":memory:");
  assert.throws(() => {
    startWorkflowRun(db, invalidDef, "dummy: yaml", "task1");
  }, /Invalid workflow definition/);
});

test("ISC 3: unknown outcome leaves run paused at current state", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "test-unknown",
    initial: "start",
    states: {
      start: { transitions: [{ outcome: "ok", to: "end" }] },
      end: { terminal: true }
    }
  };
  const run = startWorkflowRun(db, def, "name: test-unknown\ninitial: start\nstates:\n  start:\n    transitions:\n      - outcome: ok\n        to: end\n  end:\n    terminal: true", "t1", "r-unknown");

  const res = submitOutcome(db, def, {
    runId: "r-unknown",
    outcomeId: "bad_outcome_id",
    expectedRevision: 1,
  });

  assert.equal(res.status, "paused");
  const updatedRun = getRun(db, "r-unknown");
  assert.equal(updatedRun?.status, "paused");
  assert.equal(updatedRun?.current_state, "start");
  assert.equal(updatedRun?.revision, 1);
});

test("ISC 4 & 5: approval-gated transitions and stale approval rejection", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "gated-flow",
    initial: "s1",
    states: {
      s1: {
        transitions: [
          { outcome: "deploy", to: "s2", requires_approval: true },
          { outcome: "loop", to: "s1" }
        ]
      },
      s2: { terminal: true }
    }
  };
  const yaml = "name: gated-flow\ninitial: s1\nstates:\n  s1:\n    transitions:\n      - outcome: deploy\n        to: s2\n        requires_approval: true\n      - outcome: loop\n        to: s1\n  s2:\n    terminal: true";
  startWorkflowRun(db, def, yaml, "t1", "r-gate");

  // Gated transition: pauses and requires approval (ISC 4)
  const res = submitOutcome(db, def, { runId: "r-gate", outcomeId: "deploy", expectedRevision: 1 });
  assert.equal(res.status, "pending_approval");
  assert.equal(res.gate, "s2");

  const pending = getPendingApproval(db, "r-gate")!;
  assert.ok(pending);

  // Simulate looping back before approval
  db.prepare("UPDATE runs SET status = 'active' WHERE id = 'r-gate'").run();
  submitOutcome(db, def, { runId: "r-gate", outcomeId: "loop", expectedRevision: 1 }); // rev 2

  // Stale approval cannot authorize new visit/revision (ISC 5)
  assert.throws(() => {
    confirmPendingApproval(db, def, "r-gate", pending.id, true);
  }, /Stale approval cannot authorize a different state visit/);
});

test("ISC 6: resume after an injected interruption restores the last committed state", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "crash-test",
    initial: "step1",
    states: {
      step1: { transitions: [{ outcome: "next", to: "step2" }] },
      step2: { transitions: [{ outcome: "finish", to: "done" }] },
      done: { terminal: true }
    }
  };
  const yaml = "name: crash-test\ninitial: step1\nstates:\n  step1:\n    transitions:\n      - outcome: next\n        to: step2\n  step2:\n    transitions:\n      - outcome: finish\n        to: done\n  done:\n    terminal: true";
  startWorkflowRun(db, def, yaml, "t1", "r-crash");

  // Advance to step2
  submitOutcome(db, def, { runId: "r-crash", outcomeId: "next", expectedRevision: 1 });

  // Injected crash / process restart simulation: reopen from DB
  const resumedRun = resumeWorkflowRun(db, def, yaml, "r-crash");
  assert.equal(resumedRun.current_state, "step2");
  assert.equal(resumedRun.revision, 2);
  assert.equal(resumedRun.status, "active");
});

test("ISC 7: definition fingerprint mismatch blocks resume", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "fp-test",
    initial: "s1",
    states: { s1: { transitions: [{ to: "s2" }] }, s2: { terminal: true } }
  };
  const originalYaml = "name: fp-test\ninitial: s1\nstates:\n  s1:\n    transitions:\n      - to: s2\n  s2:\n    terminal: true";
  startWorkflowRun(db, def, originalYaml, "t1", "r-fp");

  const alteredYaml = originalYaml + "\n# altered";
  assert.throws(() => {
    resumeWorkflowRun(db, def, alteredYaml, "r-fp");
  }, /Definition fingerprint mismatch: resume blocked/);
});

test("ISC 8: unresolved external action is not retried automatically", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "ext-test",
    initial: "s1",
    states: { s1: { transitions: [{ to: "s2" }] }, s2: { terminal: true } }
  };
  startWorkflowRun(db, def, "name: ext-test\ninitial: s1\nstates:\n  s1:\n    transitions:\n      - to: s2\n  s2:\n    terminal: true", "t1", "r-ext");

  recordActionIntent(db, "r-ext", "git_push", { branch: "main" });

  const check = checkAndReconcileOnResume(db, "r-ext");
  assert.equal(check.requiresReconciliation, true);
  const run = getRun(db, "r-ext");
  assert.equal(run?.status, "paused");
  assert.ok(run?.pause_reason?.includes("requires user reconciliation"));
});

test("ISC 9: refinement loop pauses at configured limit", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "loop-test",
    initial: "s1",
    states: {
      s1: { transitions: [{ to: "end" }] },
      end: { terminal: true }
    }
  };
  startWorkflowRun(db, def, "name: loop-test\ninitial: s1\nstates:\n  s1:\n    transitions:\n      - to: end\n  end:\n    terminal: true", "t1", "r-loop");

  assert.equal(checkAndIncrementLoop(db, "r-loop", "tr1", 2).allowed, true);
  assert.equal(checkAndIncrementLoop(db, "r-loop", "tr1", 2).allowed, true);
  assert.equal(checkAndIncrementLoop(db, "r-loop", "tr1", 2).allowed, false);

  const run = getRun(db, "r-loop");
  assert.equal(run?.status, "paused");
});

test("ISC 10 & 11: child workflow abort distinct from success and entry override executed once", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "child-test",
    initial: "p1",
    states: { p1: { transitions: [{ to: "p2" }] }, p2: { terminal: true } }
  };
  startWorkflowRun(db, def, "name: child-test\ninitial: p1\nstates:\n  p1:\n    transitions:\n      - to: p2\n  p2:\n    terminal: true", "t1", "r-parent");

  // First invocation with entry override
  const inv1 = createChildInvocation(db, "r-parent", "child_flow", "entry_override_state");
  assert.equal(inv1.entry_override, "entry_override_state");

  // Re-retrieval across resume does not re-apply or duplicate
  const activeInv = getActiveInvocation(db, "r-parent");
  assert.equal(activeInv?.invocation_id, inv1.invocation_id);

  // Complete child as aborted (ISC 10)
  completeChildInvocation(db, inv1.invocation_id, "aborted");
  const abortedRow = db.prepare("SELECT * FROM invocations WHERE invocation_id = ?").get(inv1.invocation_id) as any;
  assert.equal(abortedRow.status, "aborted");

  // Fresh re-entry allocates new invocation
  const inv2 = createChildInvocation(db, "r-parent", "child_flow");
  assert.notEqual(inv2.invocation_id, inv1.invocation_id);
  completeChildInvocation(db, inv2.invocation_id, "completed");
  const completedRow = db.prepare("SELECT * FROM invocations WHERE invocation_id = ?").get(inv2.invocation_id) as any;
  assert.equal(completedRow.status, "completed");
});
