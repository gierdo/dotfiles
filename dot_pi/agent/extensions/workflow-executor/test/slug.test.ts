import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { slugify, parseWorkflowInvocation } from "../index.ts";

describe("slugify", () => {
  it("converts prompt into clean kebab-case slug up to 4 words", () => {
    const slug = slugify("Create authentication middleware for routes");
    assert.equal(slug, "create-authentication-middleware-for");
  });

  it("handles multi-word slugification", () => {
    const slug = slugify("move pi extension into separate repo");
    assert.equal(slug, "move-pi-extension-into");
  });

  it("falls back to 'main' for empty or whitespace-only strings", () => {
    assert.equal(slugify(""), "main");
    assert.equal(slugify("   "), "main");
    assert.equal(slugify("\t\n"), "main");
  });

  it("strips punctuation and special characters", () => {
    const slug = slugify("Fix: broken CSS styling & layout (bug #123)!");
    assert.equal(slug, "fix-broken-css-styling");
  });

  it("handles stray hyphens without creating double or dangling hyphens", () => {
    const slug = slugify("hello - world - test");
    assert.equal(slug, "hello-world-test");
  });

  it("supports custom maxWords limit", () => {
    const slug = slugify("one two three four five six", 2);
    assert.equal(slug, "one-two");
  });

  it("handles prompts with fewer words than maxWords", () => {
    assert.equal(slugify("quick fix"), "quick-fix");
    assert.equal(slugify("deploy"), "deploy");
  });
});

describe("parseWorkflowInvocation", () => {
  it("returns null for empty or whitespace rawArgs", async () => {
    assert.equal(await parseWorkflowInvocation("", {}), null);
    assert.equal(await parseWorkflowInvocation("   ", {}), null);
  });

  it("parses name only and defaults task to 'main' with empty prompt", async () => {
    const res = await parseWorkflowInvocation("interactive-planning", {});
    assert.deepEqual(res, {
      name: "interactive-planning",
      task: "main",
      prompt: "",
    });
  });

  it("parses name and treats entire rest as prompt", async () => {
    const res = await parseWorkflowInvocation("interactive-planning want to move the extension", {});
    assert.equal(res?.name, "interactive-planning");
    assert.equal(res?.prompt, "want to move the extension");
    assert.equal(res?.task, "want-to-move-the");
  });

  it("extracts explicit --slug override at beginning of rest", async () => {
    const res = await parseWorkflowInvocation("bug-fix --slug auth-fix fix login button", {});
    assert.equal(res?.name, "bug-fix");
    assert.equal(res?.task, "auth-fix");
    assert.equal(res?.prompt, "fix login button");
  });

  it("extracts explicit --slug override at end of rest", async () => {
    const res = await parseWorkflowInvocation("bug-fix fix login button --slug auth-fix", {});
    assert.equal(res?.name, "bug-fix");
    assert.equal(res?.task, "auth-fix");
    assert.equal(res?.prompt, "fix login button");
  });

  it("supports --task as an alias for --slug", async () => {
    const res = await parseWorkflowInvocation("task-implementation --task my-task write unit tests", {});
    assert.equal(res?.name, "task-implementation");
    assert.equal(res?.task, "my-task");
    assert.equal(res?.prompt, "write unit tests");
  });

  it("handles quoted --slug value", async () => {
    const res = await parseWorkflowInvocation("bug-fix --slug \"quoted-slug\" fix login button", {});
    assert.equal(res?.name, "bug-fix");
    assert.equal(res?.task, "quoted-slug");
    assert.equal(res?.prompt, "fix login button");
  });

  it("strips outer quotes from prompt if entirely quoted", async () => {
    const res = await parseWorkflowInvocation("bug-fix \"investigate and repair memory leak in cache\"", {});
    assert.equal(res?.name, "bug-fix");
    assert.equal(res?.prompt, "investigate and repair memory leak in cache");
    assert.equal(res?.task, "investigate-and-repair-memory");
  });

  it("strips optional /workflow prefix if present", async () => {
    const res = await parseWorkflowInvocation("/workflow interactive-planning build onboarding flow", {});
    assert.equal(res?.name, "interactive-planning");
    assert.equal(res?.task, "build-onboarding-flow");
    assert.equal(res?.prompt, "build onboarding flow");
  });

  it("prompts user via ctx.ui.input when interactive and slug is auto-derived", async () => {
    let capturedArg: any;
    const ctx = {
      ui: {
        async input(arg: any) {
          capturedArg = arg;
          return "custom-slug-accepted";
        },
      },
    };

    const res = await parseWorkflowInvocation("interactive-planning design new feature", ctx);
    assert.equal(res?.name, "interactive-planning");
    assert.equal(res?.task, "custom-slug-accepted");
    assert.equal(res?.prompt, "design new feature");
    assert.equal(capturedArg.value, "design-new-feature");
  });

  it("retains auto-derived slug if user cancels / dismisses ctx.ui.input", async () => {
    const ctx = {
      ui: {
        async input() {
          return undefined;
        },
      },
    };

    const res = await parseWorkflowInvocation("interactive-planning design new feature", ctx);
    assert.equal(res?.name, "interactive-planning");
    assert.equal(res?.task, "design-new-feature");
    assert.equal(res?.prompt, "design new feature");
  });

  it("does not prompt ctx.ui.input if explicit --slug is provided", async () => {
    let inputCalled = false;
    const ctx = {
      ui: {
        async input() {
          inputCalled = true;
          return "should-not-be-used";
        },
      },
    };

    const res = await parseWorkflowInvocation("bug-fix --slug explicit-slug fix login button", ctx);
    assert.equal(inputCalled, false);
    assert.equal(res?.task, "explicit-slug");
  });
});
