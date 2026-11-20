import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { createRequire } from "node:module";
import {
  initDatabase,
  getRun,
  startWorkflowRun,
  submitOutcome,
  confirmPendingApproval,
  getPendingApproval,
  type WorkflowDefinition,
} from "../runner/index.ts";
import { loadYamlParser, resolveWorkflowsDir } from "./helpers.ts";

const parse = loadYamlParser();

function loadWorkflow(name: string): { def: WorkflowDefinition; rawYaml: string } {
  const p = join(resolveWorkflowsDir(), `${name}/${name}.yaml`);
  const rawYaml = readFileSync(p, "utf-8");
  const def = parse(rawYaml);
  return { def, rawYaml };
}

function advanceThrough(db: any, def: WorkflowDefinition, rawYaml: string, runId: string, steps: { outcome: string; approve?: boolean }[]) {
  startWorkflowRun(db, def, rawYaml, "sim-task", runId);
  let revision = 1;

  for (const step of steps) {
    const res = submitOutcome(db, def, {
      runId,
      outcomeId: step.outcome,
      expectedRevision: revision,
    });

    if (res.status === "pending_approval") {
      const pending = getPendingApproval(db, runId)!;
      assert.ok(pending, `Expected pending approval for gate ${res.gate}`);
      const confirmed = confirmPendingApproval(db, def, runId, pending.id, step.approve ?? true);
      revision = confirmed.revision!;
    } else {
      revision = res.revision!;
    }
  }

  return getRun(db, runId)!;
}

test("Scenario: task-implementation reaches done and blocked", () => {
  const { def, rawYaml } = loadWorkflow("task-implementation");

  // Happy path to done
  const db1 = initDatabase(":memory:");
  const runDone = advanceThrough(db1, def, rawYaml, "ti-done", [
    { outcome: "context_ready" },
    { outcome: "implemented" },
    { outcome: "verified" },
    { outcome: "reported" },
  ]);
  assert.equal(runDone.status, "completed");
  assert.equal(runDone.current_state, "done");

  // Blocked path
  const db2 = initDatabase(":memory:");
  const runBlocked = advanceThrough(db2, def, rawYaml, "ti-blocked", [
    { outcome: "under_specified" },
  ]);
  assert.equal(runBlocked.status, "completed");
  assert.equal(runBlocked.current_state, "blocked");
});

test("Scenario: code-reconnaissance reaches done and abort", () => {
  const { def, rawYaml } = loadWorkflow("code-reconnaissance");

  const db1 = initDatabase(":memory:");
  const runDone = advanceThrough(db1, def, rawYaml, "cr-done", [
    { outcome: "questions_framed" },
    { outcome: "territory_mapped" },
    { outcome: "code_understood" },
    { outcome: "report_delivered" },
  ]);
  assert.equal(runDone.status, "completed");
  assert.equal(runDone.current_state, "done");

  const db2 = initDatabase(":memory:");
  const runAbort = advanceThrough(db2, def, rawYaml, "cr-abort", [
    { outcome: "no_codebase" },
  ]);
  assert.equal(runAbort.status, "aborted");
  assert.equal(runAbort.current_state, "abort");
});

test("Scenario: debug reaches done and abort", () => {
  const { def, rawYaml } = loadWorkflow("debug");

  const db1 = initDatabase(":memory:");
  const runDone = advanceThrough(db1, def, rawYaml, "dbg-done", [
    { outcome: "triaged" },
    { outcome: "reproduced" },
    { outcome: "diagnosed" },
  ]);
  assert.equal(runDone.status, "completed");
  assert.equal(runDone.current_state, "done");

  const db2 = initDatabase(":memory:");
  const runAbort = advanceThrough(db2, def, rawYaml, "dbg-abort", [
    { outcome: "not_a_defect" },
  ]);
  assert.equal(runAbort.status, "aborted");
  assert.equal(runAbort.current_state, "abort");
});

test("Scenario: bug-fix reaches done and handles child abort", () => {
  const { def, rawYaml } = loadWorkflow("bug-fix");

  const db1 = initDatabase(":memory:");
  const runDone = advanceThrough(db1, def, rawYaml, "bf-done", [
    { outcome: "debug_completed" },
    { outcome: "plan_ready" },
    { outcome: "fix_implemented" },
    { outcome: "fix_verified" },
    { outcome: "integration_completed", approve: true },
  ]);
  assert.equal(runDone.status, "completed");
  assert.equal(runDone.current_state, "done");

  const db2 = initDatabase(":memory:");
  const runAbort = advanceThrough(db2, def, rawYaml, "bf-abort", [
    { outcome: "debug_aborted" },
  ]);
  assert.equal(runAbort.status, "aborted");
  assert.equal(runAbort.current_state, "abort");
});

test("Scenario: feature-implementation reaches done with gate approvals", () => {
  const { def, rawYaml } = loadWorkflow("feature-implementation");

  const db = initDatabase(":memory:");
  const run = advanceThrough(db, def, rawYaml, "feat-done", [
    { outcome: "oriented" },
    { outcome: "specified" },
    { outcome: "implemented" },
    { outcome: "verified" },
    { outcome: "review_passed" },
    { outcome: "integrated", approve: true },
  ]);
  assert.equal(run.status, "completed");
  assert.equal(run.current_state, "done");
});

test("Scenario: feature-implementation handles child task-implementation blocked", () => {
  const { def, rawYaml } = loadWorkflow("feature-implementation");

  const db = initDatabase(":memory:");
  const run = advanceThrough(db, def, rawYaml, "feat-blocked", [
    { outcome: "oriented" },
    { outcome: "specified" },
    { outcome: "implementation_blocked" },
    { outcome: "plan_reconciled" },
    { outcome: "implemented" },
    { outcome: "verified" },
    { outcome: "review_passed" },
    { outcome: "integrated", approve: true },
  ]);
  assert.equal(run.status, "completed");
  assert.equal(run.current_state, "done");
});

test("Scenario: interactive-planning reaches done with consent gates", () => {
  const { def, rawYaml } = loadWorkflow("interactive-planning");

  const db = initDatabase(":memory:");
  const run = advanceThrough(db, def, rawYaml, "ip-done", [
    { outcome: "oriented" },
    { outcome: "intent_confirmed", approve: true },
    { outcome: "requirements_confirmed", approve: true },
    { outcome: "isc_confirmed", approve: true },
    { outcome: "approach_selected", approve: true },
    { outcome: "design_validated", approve: true },
    { outcome: "risks_resolved", approve: true },
    { outcome: "plan_approved", approve: true },
    { outcome: "tasks_approved", approve: true },
  ]);
  assert.equal(run.status, "completed");
  assert.equal(run.current_state, "done");
});

test("Scenario: merge-review reaches done with approval", () => {
  const { def, rawYaml } = loadWorkflow("merge-review");

  const db = initDatabase(":memory:");
  const run = advanceThrough(db, def, rawYaml, "mr-done", [
    { outcome: "scope_established" },
    { outcome: "understood" },
    { outcome: "assessed" },
    { outcome: "triaged", approve: true },
    { outcome: "delivered" },
  ]);
  assert.equal(run.status, "completed");
  assert.equal(run.current_state, "done");
});

test("Scenario: refactoring reaches done", () => {
  const { def, rawYaml } = loadWorkflow("refactoring");

  const db = initDatabase(":memory:");
  const run = advanceThrough(db, def, rawYaml, "refact-done", [
    { outcome: "goal_defined" },
    { outcome: "baseline_established" },
    { outcome: "plan_ready" },
    { outcome: "transformed" },
    { outcome: "verified" },
  ]);
  assert.equal(run.status, "completed");
  assert.equal(run.current_state, "done");
});
