import test from "node:test";
import assert from "node:assert/strict";
import workflowExtension from "../index.ts";

test("workflow extension registers commands and tools", async () => {
  const registeredCommands: string[] = [];
  const registeredTools: string[] = [];

  const mockPi: any = {
    registerCommand(name: string) {
      registeredCommands.push(name);
    },
    registerTool(opts: any) {
      registeredTools.push(opts.name);
    },
  };

  await workflowExtension(mockPi);
  assert.ok(registeredCommands.includes("workflow"));
  assert.equal(registeredCommands.includes("workflows"), false);
  assert.ok(registeredTools.includes("workflow_transition"));
  assert.ok(registeredTools.includes("workflow_list"));
});

test("workflow_transition tool supports three-option approval dialogue: Approve, Reject, Chat", async () => {
  let toolHandler: any;
  const mockPi: any = {
    registerCommand() {},
    registerTool(opts: any) {
      if (opts.name === "workflow_transition") toolHandler = opts.execute;
    },
  };

  await workflowExtension(mockPi);
  assert.ok(toolHandler);
  assert.equal(typeof toolHandler, "function");

  // Mock UI context simulating selecting "Chat about it" and asking a question
  let selectCalled = false;
  let inputCalled = false;
  const mockCtx: any = {
    ui: {
      async select(prompt: string, options: string[]) {
        selectCalled = true;
        assert.equal(options.length, 3);
        assert.ok(options[0].includes("Approve"));
        assert.ok(options[1].includes("Reject"));
        assert.ok(options[2].includes("Chat about it"));
        return options[2]; // Select Chat about it
      },
      async input(title: string, placeholder?: string) {
        inputCalled = true;
        return "Can you explain why this gate is reached?";
      }
    }
  };

  assert.ok(mockCtx.ui.select);
  assert.ok(mockCtx.ui.input);
});
