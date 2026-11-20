import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const skillDir = fileURLToPath(new URL("../skills/workflow-executor/", import.meta.url));
const workflowsDir = join(skillDir, "workflows");
const usage = "Usage: /workflow <name> [instructions]";

function definition(name: string): string {
  return join(workflowsDir, name, `${name}.yaml`);
}

function workflowNames(): string[] {
  try {
    return readdirSync(workflowsDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .filter((name) => /^[a-z0-9][a-z0-9-]*$/.test(name) && statSync(definition(name), { throwIfNoEntry: false })?.isFile())
      .sort();
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return [];
    throw error;
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("workflow", {
    description: "Run a workflow from the workflow-executor skill",
    getArgumentCompletions: (prefix) => {
      const input = prefix.trimStart();
      if (/\s/.test(input)) return null;
      const matches = workflowNames().filter((name) => name.startsWith(input));
      return matches.length ? matches.map((name) => ({ label: name, value: `${name} ` })) : null;
    },
    handler: async (args, ctx) => {
      const [, name, instructions] = /^(\S+)(?:\s+([\s\S]*))?$/.exec(args.trim()) ?? [];
      const names = workflowNames();
      if (!names.length) {
        ctx.ui.notify(`No workflows found in ${workflowsDir}`, "warning");
        return;
      }
      if (!name || !names.includes(name)) {
        const problem = name ? `Unknown workflow: ${name}\n` : "";
        ctx.ui.notify(`${problem}${usage}\nAvailable: ${names.join(", ")}`, name ? "warning" : "info");
        return;
      }

      const prompt = `Run the ${name} workflow using the workflow-executor skill. Read ${join(skillDir, "SKILL.md")} and ${definition(name)} before proceeding.`;
      const message = instructions ? `${prompt}\n\nUser instructions:\n${instructions}` : prompt;
      pi.sendUserMessage(message, ctx.isIdle() ? undefined : { deliverAs: "followUp" });
    },
  });
}
