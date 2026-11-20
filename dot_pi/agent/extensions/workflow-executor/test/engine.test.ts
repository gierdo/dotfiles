import test from "node:test";
import assert from "node:assert/strict";
import { initDatabase, getRun, getPendingApproval } from "../runner/db.ts";
import {
  startWorkflowRun,
  resumeWorkflowRun,
  submitOutcome,
  confirmPendingApproval,
} from "../runner/engine.ts";
import type { WorkflowDefinition } from "../runner/types.ts";

const mockDefYaml = `
name: sample-workflow
initial: intake
states:
  intake:
    transitions:
      - outcome: valid
        to: review
        reason: "task valid"
  review:
    transitions:
      - outcome: approved
        to: deploy
        reason: "deploy approved"
        requires_approval: true
      - outcome: retry
        to: intake
        reason: "retry intake"
  deploy:
    terminal: true
`;

const mockDef: WorkflowDefinition = {
  name: "sample-workflow",
  initial: "intake",
  states: {
    intake: {
      transitions: [
        { outcome: "valid", to: "review", reason: "task valid" }
      ]
    },
    review: {
      transitions: [
        { outcome: "approved", to: "deploy", reason: "deploy approved", requires_approval: true },
        { outcome: "retry", to: "intake", reason: "retry intake" }
      ]
    },
    deploy: {
      terminal: true
    }
  }
};

test("startWorkflowRun creates new run and verifies fingerprint", () => {
  const db = initDatabase(":memory:");
  const run = startWorkflowRun(db, mockDef, mockDefYaml, "test-task", "r-1");
  assert.equal(run.id, "r-1");
  assert.equal(run.current_state, "intake");
  assert.equal(run.revision, 1);
});

test("resumeWorkflowRun detects fingerprint mismatch and blocks (ISC 7)", () => {
  const db = initDatabase(":memory:");
  startWorkflowRun(db, mockDef, mockDefYaml, "test-task", "r-1");

  const alteredYaml = mockDefYaml + "\n# altered definition";
  assert.throws(() => {
    resumeWorkflowRun(db, mockDef, alteredYaml, "r-1");
  }, /Definition fingerprint mismatch: resume blocked/);

  const run = getRun(db, "r-1");
  assert.equal(run?.status, "paused");
});

test("submitOutcome pauses run on unknown outcome (ISC 3)", () => {
  const db = initDatabase(":memory:");
  startWorkflowRun(db, mockDef, mockDefYaml, "test-task", "r-1");

  const result = submitOutcome(db, mockDef, {
    runId: "r-1",
    outcomeId: "unknown_weird_outcome",
    expectedRevision: 1,
  });

  assert.equal(result.status, "paused");
  assert.ok(result.reason?.includes("Unknown outcome"));

  const run = getRun(db, "r-1");
  assert.equal(run?.status, "paused");
  assert.equal(run?.current_state, "intake"); // Did not advance
});

test("approval-gated transition creates pending approval and pauses (ISC 4)", () => {
  const db = initDatabase(":memory:");
  startWorkflowRun(db, mockDef, mockDefYaml, "test-task", "r-1");

  // Advance intake -> review
  submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "valid", expectedRevision: 1 });

  // Submit outcome that requires approval
  const res = submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "approved", expectedRevision: 2 });
  assert.equal(res.status, "pending_approval");
  assert.equal(res.gate, "deploy");

  const run = getRun(db, "r-1");
  assert.equal(run?.status, "paused");
  assert.equal(run?.current_state, "review"); // Cannot advance without approval

  const pending = getPendingApproval(db, "r-1");
  assert.ok(pending);
  assert.equal(pending.target_state, "deploy");

  // Now confirm approval explicitly
  const finalRes = confirmPendingApproval(db, mockDef, "r-1", pending.id, true);
  assert.equal(finalRes.status, "terminal");
  assert.equal(finalRes.nextState, "deploy");

  const completedRun = getRun(db, "r-1");
  assert.equal(completedRun?.status, "completed");
  assert.equal(completedRun?.current_state, "deploy");
});

test("stale approval cannot authorize a later visit to the same gate (ISC 5)", () => {
  const db = initDatabase(":memory:");
  startWorkflowRun(db, mockDef, mockDefYaml, "test-task", "r-1");

  // Advance intake -> review (revision 1 -> 2)
  submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "valid", expectedRevision: 1 });

  // Gated transition: review -> deploy creates pending approval (revision 2)
  submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "approved", expectedRevision: 2 });
  const pending = getPendingApproval(db, "r-1")!;

  // User decides not to approve yet, instead loops back: review -> intake
  // (simulate state visit changing or revision incrementing)
  db.prepare("UPDATE runs SET status = 'active' WHERE id = 'r-1'").run();
  submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "retry", expectedRevision: 2 }); // now at intake, rev 3

  // Advance intake -> review again (now visit 3, rev 4)
  submitOutcome(db, mockDef, { runId: "r-1", outcomeId: "valid", expectedRevision: 3 });

  // Try to use the old approval from earlier visit:
  assert.throws(() => {
    confirmPendingApproval(db, mockDef, "r-1", pending.id, true);
  }, /Stale approval cannot authorize a different state visit/);
});

test("submitOutcome pauses run when transition max_retries limit is exceeded (P1 finding)", () => {
  const db = initDatabase(":memory:");
  const def: WorkflowDefinition = {
    name: "retry-flow",
    initial: "stepA",
    states: {
      stepA: {
        transitions: [{ outcome: "loop", to: "stepA", max_retries: 2 }, { outcome: "done", to: "end" }]
      },
      end: { terminal: true }
    }
  };
  const yaml = "name: retry-flow\ninitial: stepA\nstates:\n  stepA:\n    transitions:\n      - outcome: loop\n        to: stepA\n        max_retries: 2\n      - outcome: done\n        to: end\n  end:\n    terminal: true";
  startWorkflowRun(db, def, yaml, "t", "r-max-retries");

  // Attempt 1: loop allowed
  const res1 = submitOutcome(db, def, { runId: "r-max-retries", outcomeId: "loop", expectedRevision: 1 });
  assert.equal(res1.status, "advanced");

  // Attempt 2: loop allowed
  const res2 = submitOutcome(db, def, { runId: "r-max-retries", outcomeId: "loop", expectedRevision: 2 });
  assert.equal(res2.status, "advanced");

  // Attempt 3: limit of 2 reached -> paused!
  const res3 = submitOutcome(db, def, { runId: "r-max-retries", outcomeId: "loop", expectedRevision: 3 });
  assert.equal(res3.status, "paused");
  assert.ok(res3.reason?.includes("Loop thrash guard"));

  const run = getRun(db, "r-max-retries");
  assert.equal(run?.status, "paused");
});
