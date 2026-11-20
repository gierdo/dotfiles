import { readdirSync, statSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as runner from "./runner/index.ts";

const require = createRequire(import.meta.url);
const homeDir = process.env.HOME || "";

function getActivePiNodeModules(): string | null {
  try {
    const versionFile = join(homeDir, ".pi/agent/install/current-version");
    if (existsSync(versionFile)) {
      const version = readFileSync(versionFile, "utf-8").trim();
      const nm = join(homeDir, ".pi/agent/install/releases", version, "node_modules");
      if (existsSync(nm)) return nm;
    }
  } catch {
    // Ignore error
  }
  return null;
}

const piModules = getActivePiNodeModules();

let parseYaml: (text: string) => any;
try {
  parseYaml = require("yaml").parse;
} catch {
  if (piModules) {
    parseYaml = require(join(piModules, "yaml")).parse;
  } else {
    throw new Error("Unable to resolve YAML parser: install 'yaml' or run under active Pi runtime");
  }
}

let Type: any;
try {
  Type = (await import("typebox")).Type;
} catch {
  if (piModules) {
    try {
      Type = (await import(join(piModules, "typebox/build/index.mjs"))).Type;
    } catch {
      // Fallback below
    }
  }
  if (!Type) {
    Type = {
      Object: (props: any) => ({ type: "object", properties: props, required: Object.keys(props) }),
      String: (desc?: any) => ({ type: "string", ...desc }),
      Integer: (desc?: any) => ({ type: "integer", ...desc }),
      Optional: (schema: any) => ({ ...schema, optional: true }),
      Array: (schema: any, desc?: any) => ({ type: "array", items: schema, ...desc }),
    };
  }
}

function resolveSkillDir(): string {
  // 1. Deployed location: ~/.pi/agent/skills/workflow-executor
  const deployed = fileURLToPath(new URL("../../skills/workflow-executor/", import.meta.url));
  if (existsSync(deployed)) return deployed;

  // 2. Local chezmoi repository: <sourceDir>/skills/workflow-executor
  const repo = fileURLToPath(new URL("../../../../skills/workflow-executor/", import.meta.url));
  if (existsSync(repo)) return repo;

  // 3. Fallback to process.cwd() or home
  const cwdSkills = join(process.cwd(), "skills/workflow-executor");
  if (existsSync(cwdSkills)) return cwdSkills;

  return join(homeDir, ".pi/agent/skills/workflow-executor");
}

const skillDir = resolveSkillDir();
const workflowsDir = join(skillDir, "workflows");
const usage = "Usage: /workflow <name> [task-slug] [instructions]";

function definitionPath(name: string): string {
  return join(workflowsDir, name, `${name}.yaml`);
}

function workflowNames(): string[] {
  try {
    return readdirSync(workflowsDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .filter((name) => /^[a-z0-9][a-z0-9-]*$/.test(name) && statSync(definitionPath(name), { throwIfNoEntry: false })?.isFile())
      .sort();
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return [];
    throw error;
  }
}

export default async function (pi: ExtensionAPI) {
  function getDB() {
    const dbPath = join(process.cwd(), ".workflow", "state.db");
    return runner.initDatabase(dbPath);
  }

  function getJournalPath(workflow: string, task: string): string {
    return join(process.cwd(), ".workflow", "runs", workflow, task, "workflow-log.md");
  }

  async function resumeRunById(runId: string, ctx: any, instructions?: string) {
    const db = getDB();
    let run = runner.getRun(db, runId);
    if (!run) {
      ctx.ui.notify(`Run '${runId}' not found in .workflow/state.db`, "error");
      return;
    }

    const rawYaml = readFileSync(definitionPath(run.workflow), "utf-8");
    const def = parseYaml(rawYaml);
    const journalPath = getJournalPath(run.workflow, run.task);

    try {
      run = runner.resumeWorkflowRun(db, def, rawYaml, runId);
    } catch (err) {
      ctx.ui.notify(`Workflow resume blocked: ${(err as Error).message}`, "error");
      return;
    }

    const actCheck = runner.checkAndReconcileOnResume(db, runId);
    if (actCheck.requiresReconciliation) {
      runner.syncMarkdownJournal(db, runId, journalPath);
      ctx.ui.notify(`Unconfirmed external action #${actCheck.pendingAction.id} requires user reconciliation. Run is paused.`, "warning");
      return;
    }

    runner.syncMarkdownJournal(db, runId, journalPath);
    ctx.ui.notify(`Resumed workflow '${run.workflow}' (${run.task}) at state '${run.current_state}' [revision ${run.revision}]`, "info");

    const prompt = `Run the ${run.workflow} workflow using the workflow-executor skill. Read ${join(skillDir, "SKILL.md")} and ${definitionPath(run.workflow)} before proceeding.\n\nActive run ID: \`${run.id}\` | State: \`${run.current_state}\` | Revision: ${run.revision}\n\nMANDATORY: You MUST drive this workflow through the transition runner using the \`workflow_transition\` tool.\n- For transitions without \`requires_approval: true\`, advance autonomously using \`workflow_transition\` and immediately continue working in the next state without stopping to ask the user.\n- For transitions with \`requires_approval: true\`, calling \`workflow_transition\` triggers an interactive user approval dialog.\n- Do not simulate transitions in chat text; state only advances when committed via \`workflow_transition\`.`;
    const extraInstructions = instructions ? `\n\nUser instructions:\n${instructions}` : "";
    pi.sendUserMessage(`${prompt}${extraInstructions}`, ctx.isIdle() ? undefined : { deliverAs: "followUp" });
  }

  async function showWorkflowsInterface(ctx: any) {
    const db = getDB();
    const runs = runner.listRuns(db);
    if (!runs || runs.length === 0) {
      ctx.ui.notify("No workflow runs found in .workflow/state.db", "info");
      return;
    }

    const options = runs.map((r: any) => {
      const badge = `[${r.status.toUpperCase()}]`;
      const pauseInfo = r.pause_reason ? ` - ${r.pause_reason}` : "";
      return `${badge} ${r.workflow} (${r.task}) - state: ${r.current_state}, rev: ${r.revision}${pauseInfo}`;
    });

    const choice = await ctx.ui.select("Select a workflow run to inspect or resume:", options);
    if (!choice) return;

    const selectedIndex = options.indexOf(choice);
    const selectedRun = runs[selectedIndex];
    if (!selectedRun) return;

    if (selectedRun.status === "completed" || selectedRun.status === "aborted") {
      const journalPath = getJournalPath(selectedRun.workflow, selectedRun.task);
      ctx.ui.notify(`Workflow '${selectedRun.workflow}' (${selectedRun.task}) is ${selectedRun.status} at state '${selectedRun.current_state}'. Journal: ${journalPath}`, "info");
      return;
    }

    // Active or paused: resume directly
    await resumeRunById(selectedRun.id, ctx);
  }

  pi.registerCommand("workflow", {
    description: "Run or resume a workflow from the workflow-executor skill (run without args to list runs)",
    getArgumentCompletions: (prefix) => {
      const input = prefix.trimStart();
      if (/\s/.test(input)) return null;
      const matches = workflowNames().filter((name) => name.startsWith(input));
      return matches.length ? matches.map((name) => ({ label: name, value: `${name} ` })) : null;
    },
    handler: async (args, ctx) => {
      if (!args || !args.trim() || args.trim() === "list") {
        await showWorkflowsInterface(ctx);
        return;
      }

      // Quote-aware argument extraction
      const matches = args.trim().match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g) || [];
      const cleanArgs = matches.map(m => m.replace(/^["']|["']$/g, "").trim());
      const name = cleanArgs[0];
      const rawTask = cleanArgs[1];
      const instructions = cleanArgs.slice(2).join(" ");

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

      const rawYaml = readFileSync(definitionPath(name), "utf-8");
      const def = parseYaml(rawYaml);
      const db = getDB();

      // Convert task to kebab-case slug if provided, default to 'main'
      const task = rawTask ? rawTask.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") : "main";
      const runId = `${name}-${task || "main"}`;

      let run = runner.getRun(db, runId);
      if (run) {
        await resumeRunById(runId, ctx, instructions);
      } else {
        // Start fresh run
        try {
          run = runner.startWorkflowRun(db, def, rawYaml, task, runId);
          const journalPath = getJournalPath(name, task);
          runner.syncMarkdownJournal(db, runId, journalPath);
          ctx.ui.notify(`Started workflow '${name}' (${task}) at initial state '${run.current_state}'`, "info");
        } catch (err) {
          ctx.ui.notify(`Failed to start workflow: ${(err as Error).message}`, "error");
          return;
        }

        const prompt = `Run the ${name} workflow using the workflow-executor skill. Read ${join(skillDir, "SKILL.md")} and ${definitionPath(name)} before proceeding.\n\nActive run ID: \`${run.id}\` | State: \`${run.current_state}\` | Revision: ${run.revision}\n\nMANDATORY: You MUST drive this workflow through the transition runner using the \`workflow_transition\` tool.\n- For transitions without \`requires_approval: true\`, advance autonomously using \`workflow_transition\` and immediately continue working in the next state without stopping to ask the user.\n- For transitions with \`requires_approval: true\`, calling \`workflow_transition\` triggers an interactive user approval dialog.\n- Do not simulate transitions in chat text; state only advances when committed via \`workflow_transition\`.`;
        const extraInstructions = instructions ? `\n\nUser instructions:\n${instructions}` : "";
        pi.sendUserMessage(`${prompt}${extraInstructions}`, ctx.isIdle() ? undefined : { deliverAs: "followUp" });
      }
    },
  });

  pi.registerTool({
    name: "workflow_transition",
    label: "Workflow Transition",
    description: "Submit a workflow state outcome to advance the workflow runner.",
    parameters: Type.Object({
      runId: Type.String({ description: "Active run ID" }),
      outcomeId: Type.String({ description: "Outcome ID defined in current state transitions" }),
      expectedRevision: Type.Integer({ description: "Expected current run revision" }),
      evidence: Type.Optional(Type.Array(Type.String(), { description: "Evidence references" })),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const db = getDB();
      const run = runner.getRun(db, params.runId);
      if (!run) {
        return {
          content: [{ type: "text", text: `Error: Run '${params.runId}' not found.` }],
          details: { error: "run_not_found" },
        };
      }

      const rawYaml = readFileSync(definitionPath(run.workflow), "utf-8");
      const def = parseYaml(rawYaml);
      const journalPath = getJournalPath(run.workflow, run.task);

      try {
        const result = runner.submitOutcome(db, def, {
          runId: params.runId,
          outcomeId: params.outcomeId,
          expectedRevision: params.expectedRevision,
          evidence: params.evidence,
        });

        if (result.status === "pending_approval") {
          const pending = runner.getPendingApproval(db, params.runId);
          if (!pending) {
            throw new Error("Pending approval record not found");
          }

          const prompt = `Workflow '${run.workflow}' (${run.task}) requires approval to transition to '${result.gate}'.\nReason: ${result.reason ?? "None provided"}`;
          const options = [
            `Approve transition to '${result.gate}'`,
            `Reject transition`,
            `Chat about it (ask question or discuss)`,
          ];

          const choice = await ctx.ui.select(prompt, options);

          if (choice === options[0]) {
            // Option 1: Approved
            const finalResult = runner.confirmPendingApproval(db, def, params.runId, pending.id, true);
            runner.syncMarkdownJournal(db, params.runId, journalPath);
            return {
              content: [{
                type: "text",
                text: `Gate approved by user. Advanced to state '${finalResult.nextState}' [revision ${finalResult.revision}].`,
              }],
              details: finalResult,
            };
          } else if (choice === options[2]) {
            // Option 3: Chat about it
            const userPrompt = await ctx.ui.input(
              "Ask a question or provide feedback before deciding:",
              "What would you like to know or adjust before approving?"
            );

            if (!userPrompt || !userPrompt.trim()) {
              return {
                content: [{
                  type: "text",
                  text: `User chose to discuss the transition to '${result.gate}' but dismissed the input. Run remains in '${run.current_state}'. Call workflow_transition again when ready to present the dialogue.`,
                }],
                details: { status: "discussing_cancelled", gate: result.gate },
              };
            }

            return {
              content: [{
                type: "text",
                text: `The user requested to discuss this transition before deciding on approval.\n\nUser question / prompt:\n"${userPrompt.trim()}"\n\nINSTRUCTIONS FOR AGENT:\n1. Answer the user's question thoroughly and directly in your response.\n2. Once you have answered, call the \`workflow_transition\` tool again with the exact same parameters:\n   - runId: "${params.runId}"\n   - outcomeId: "${params.outcomeId}"\n   - expectedRevision: ${params.expectedRevision}\n   This will immediately display the approval dialogue to the user again with the latest context.`,
              }],
              details: { status: "discussing", gate: result.gate, userPrompt: userPrompt.trim() },
            };
          } else if (choice === options[1]) {
            // Option 2: Rejected
            const finalResult = runner.confirmPendingApproval(db, def, params.runId, pending.id, false);
            runner.syncMarkdownJournal(db, params.runId, journalPath);
            return {
              content: [{
                type: "text",
                text: `Gate transition to '${result.gate}' was REJECTED by user. Run paused at '${run.current_state}'.`,
              }],
              details: finalResult,
            };
          } else {
            // Dialog dismissed without selection
            runner.syncMarkdownJournal(db, params.runId, journalPath);
            return {
              content: [{
                type: "text",
                text: `Approval dialogue was dismissed without a selection. Run remains paused at '${run.current_state}'. Call workflow_transition again when ready.`,
              }],
              details: { status: "dismissed", gate: result.gate },
            };
          }
        }

        runner.syncMarkdownJournal(db, params.runId, journalPath);

        return {
          content: [{
            type: "text",
            text: `Workflow transitioned: status=${result.status}, state=${result.nextState ?? run.current_state}, revision=${result.revision}`,
          }],
          details: result,
        };
      } catch (err) {
        return {
          content: [{ type: "text", text: `Transition error: ${(err as Error).message}` }],
          details: { error: (err as Error).message },
        };
      }
    },
  });

  pi.registerTool({
    name: "workflow_list",
    label: "Workflow List",
    description: "List currently active, paused, or completed workflow runs from .workflow/state.db",
    parameters: Type.Object({
      status: Type.Optional(Type.String({ description: "Optional status filter: active, paused, completed, aborted" })),
    }),
    async execute(toolCallId, params) {
      const db = getDB();
      const runs = runner.listRuns(db, params.status);
      const text = runs.map((r: any) =>
        `- \`${r.id}\` [${r.status.toUpperCase()}] workflow: ${r.workflow}, task: ${r.task}, state: ${r.current_state}, rev: ${r.revision}${r.pause_reason ? ` (paused: ${r.pause_reason})` : ""}`
      ).join("\n") || "No workflow runs found.";
      return {
        content: [{ type: "text", text }],
        details: { runs },
      };
    },
  });
}
