import test from "node:test";
import assert from "node:assert/strict";
import { initDatabase, createRun, getRun } from "../runner/db.ts";
import {
  checkAndIncrementLoop,
  getLoopCount,
  createChildInvocation,
  getActiveInvocation,
  completeChildInvocation,
} from "../runner/invocations.ts";

test("checkAndIncrementLoop pauses run at max_retries limit (ISC 9)", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-loop",
    task: "t",
    workflow: "wf",
    initialState: "stateA",
    definitionFingerprint: "fp",
  });

  const res1 = checkAndIncrementLoop(db, "run-loop", "tr_refine", 2);
  assert.equal(res1.allowed, true);
  assert.equal(res1.count, 1);

  const res2 = checkAndIncrementLoop(db, "run-loop", "tr_refine", 2);
  assert.equal(res2.allowed, true);
  assert.equal(res2.count, 2);

  // Third attempt exceeds limit of 2:
  const res3 = checkAndIncrementLoop(db, "run-loop", "tr_refine", 2);
  assert.equal(res3.allowed, false);
  assert.equal(res3.count, 2);

  const run = getRun(db, "run-loop");
  assert.equal(run?.status, "paused");
  assert.ok(run?.pause_reason?.includes("Loop thrash guard"));
});

test("child invocation applies entry override once and preserves active invocation across resume (ISC 11)", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "parent-1",
    task: "t",
    workflow: "parent_wf",
    initialState: "invoke_child",
    definitionFingerprint: "fp",
  });

  // Launch child with entry override
  const inv = createChildInvocation(db, "parent-1", "child_wf", "step_custom");
  assert.equal(inv.status, "active");
  assert.equal(inv.entry_override, "step_custom");

  // On resume, getActiveInvocation retrieves existing invocation rather than creating a new one
  const active = getActiveInvocation(db, "parent-1");
  assert.ok(active);
  assert.equal(active.invocation_id, inv.invocation_id);
  assert.equal(active.entry_override, "step_custom");
});

test("child abort is distinguishable from success in persisted outcome (ISC 10)", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "parent-2",
    task: "t",
    workflow: "parent_wf",
    initialState: "invoke_child",
    definitionFingerprint: "fp",
  });

  const invSuccess = createChildInvocation(db, "parent-2", "child_wf");
  completeChildInvocation(db, invSuccess.invocation_id, "completed");

  const rowSuccess = db.prepare("SELECT * FROM invocations WHERE invocation_id = ?").get(invSuccess.invocation_id) as { status: string };
  assert.equal(rowSuccess.status, "completed");

  // Re-entry opens fresh invocation ID
  const invAbort = createChildInvocation(db, "parent-2", "child_wf");
  assert.notEqual(invAbort.invocation_id, invSuccess.invocation_id);

  completeChildInvocation(db, invAbort.invocation_id, "aborted");
  const rowAbort = db.prepare("SELECT * FROM invocations WHERE invocation_id = ?").get(invAbort.invocation_id) as { status: string };
  assert.equal(rowAbort.status, "aborted");
});
