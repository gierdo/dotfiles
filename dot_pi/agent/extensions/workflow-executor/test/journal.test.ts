import test from "node:test";
import assert from "node:assert/strict";
import { initDatabase, createRun, executeTransition, pauseRun, createPendingApproval, resolvePendingApproval } from "../runner/db.ts";
import { renderMarkdownJournal } from "../runner/journal.ts";

test("renderMarkdownJournal projects run history faithfully", () => {
  const db = initDatabase(":memory:");
  createRun(db, {
    id: "run-j-1",
    task: "test-feature",
    workflow: "feature-impl",
    initialState: "orientation",
    definitionFingerprint: "abcdef1234567890abcdef1234567890",
  });

  executeTransition(db, {
    runId: "run-j-1",
    expectedRevision: 1,
    toState: "specification",
    outcomeId: "oriented",
    reason: "orientation complete",
  });

  const app = createPendingApproval(db, "run-j-1", 2, "implementation", 2, "spec signed off");
  resolvePendingApproval(db, app.id, "approved");

  const md = renderMarkdownJournal(db, "run-j-1");
  assert.ok(md.includes("# Workflow: feature-impl (test-feature)"));
  assert.ok(md.includes("State: `orientation` (Visit #1)"));
  assert.ok(md.includes("Transition: `orientation` -> `specification`"));
  assert.ok(md.includes("Outcome: `oriented`"));
  assert.ok(md.includes("Gate: `implementation` | Status: `approved`"));
});
