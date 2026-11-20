import test from "node:test";
import assert from "node:assert/strict";
import { validateDefinition, computeFingerprint } from "../runner/validator.ts";
import type { WorkflowDefinition } from "../runner/types.ts";

test("computeFingerprint produces deterministic sha256 hex string", () => {
  const hash1 = computeFingerprint("name: test\ninitial: start");
  const hash2 = computeFingerprint("name: test\ninitial: start");
  const hash3 = computeFingerprint("name: test\ninitial: other");
  assert.equal(hash1, hash2);
  assert.notEqual(hash1, hash3);
  assert.equal(hash1.length, 64);
});

test("computeFingerprint normalizes CRLF and LF line endings to identical hash", () => {
  const lf = "name: test\ninitial: start\nstates:\n  start:\n    terminal: true\n";
  const crlf = "name: test\r\ninitial: start\r\nstates:\r\n  start:\r\n    terminal: true\r\n";
  assert.equal(computeFingerprint(crlf), computeFingerprint(lf));
});

test("validateDefinition accepts valid workflow definition", () => {
  const def: WorkflowDefinition = {
    name: "simple-flow",
    initial: "step1",
    states: {
      step1: {
        goal: "Do step 1",
        transitions: [
          { outcome: "done", to: "completed", reason: "step 1 finished" }
        ]
      },
      completed: {
        terminal: true,
        goal: "Finished"
      }
    }
  };

  const res = validateDefinition(def);
  assert.equal(res.valid, true);
  assert.equal(res.errors.length, 0);
});

test("validateDefinition rejects missing initial state", () => {
  const def: WorkflowDefinition = {
    name: "invalid-flow",
    initial: "non_existent",
    states: {
      step1: {
        transitions: [{ to: "done" }]
      },
      done: { terminal: true }
    }
  };

  const res = validateDefinition(def);
  assert.equal(res.valid, false);
  assert.ok(res.errors.some(e => e.includes("Initial state 'non_existent' is not declared")));
});

test("validateDefinition rejects dangling transition target", () => {
  const def: WorkflowDefinition = {
    name: "invalid-target",
    initial: "step1",
    states: {
      step1: {
        transitions: [{ to: "ghost_state" }]
      },
      done: { terminal: true }
    }
  };

  const res = validateDefinition(def);
  assert.equal(res.valid, false);
  assert.ok(res.errors.some(e => e.includes("targets unknown state 'ghost_state'")));
});

test("validateDefinition rejects non-terminal state without transitions", () => {
  const def: WorkflowDefinition = {
    name: "no-transitions",
    initial: "step1",
    states: {
      step1: {},
      done: { terminal: true }
    }
  };

  const res = validateDefinition(def);
  assert.equal(res.valid, false);
  assert.ok(res.errors.some(e => e.includes("Non-terminal state 'step1' has no transitions")));
});

test("validateDefinition rejects definition without any terminal state", () => {
  const def: WorkflowDefinition = {
    name: "no-terminal",
    initial: "loop",
    states: {
      loop: {
        transitions: [{ to: "loop" }]
      }
    }
  };

  const res = validateDefinition(def);
  assert.equal(res.valid, false);
  assert.ok(res.errors.some(e => e.includes("at least one terminal state")));
});

test("validateDefinition accepts valid subagent string and object", () => {
  const defString: WorkflowDefinition = {
    name: "subagent-str",
    initial: "s1",
    states: {
      s1: {
        subagent: "reviewer",
        transitions: [{ to: "done" }]
      },
      done: { terminal: true }
    }
  };
  assert.equal(validateDefinition(defString).valid, true);

  const defObj: WorkflowDefinition = {
    name: "subagent-obj",
    initial: "s1",
    states: {
      s1: {
        subagent: { agent: "worker", skills: "software-engineering" },
        transitions: [{ to: "done" }]
      },
      done: { terminal: true }
    }
  };
  assert.equal(validateDefinition(defObj).valid, true);
});

test("validateDefinition rejects invalid subagent declaration", () => {
  const defEmpty: WorkflowDefinition = {
    name: "subagent-empty",
    initial: "s1",
    states: {
      s1: {
        subagent: "   ",
        transitions: [{ to: "done" }]
      },
      done: { terminal: true }
    }
  };
  const resEmpty = validateDefinition(defEmpty);
  assert.equal(resEmpty.valid, false);
  assert.ok(resEmpty.errors.some(e => e.includes("empty 'subagent' name")));

  const defMissingAgent: WorkflowDefinition = {
    name: "subagent-bad-obj",
    initial: "s1",
    states: {
      s1: {
        subagent: { skills: "foo" } as any,
        transitions: [{ to: "done" }]
      },
      done: { terminal: true }
    }
  };
  const resMissing = validateDefinition(defMissingAgent);
  assert.equal(resMissing.valid, false);
  assert.ok(resMissing.errors.some(e => e.includes("missing required 'agent' name")));
});
