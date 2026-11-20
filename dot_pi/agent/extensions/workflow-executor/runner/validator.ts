import { createHash } from "node:crypto";
import type { WorkflowDefinition, ValidationResult } from "./types.ts";

export function computeFingerprint(rawYaml: string): string {
  return createHash("sha256").update(rawYaml.replace(/\r\n/g, "\n").trim()).digest("hex");
}

export function validateDefinition(def: WorkflowDefinition): ValidationResult {
  const errors: string[] = [];

  if (!def || typeof def !== "object") {
    return { valid: false, errors: ["Definition must be an object"] };
  }

  if (!def.name || typeof def.name !== "string" || !/^[a-z0-9][a-z0-9-]*$/.test(def.name)) {
    errors.push(`Invalid workflow name '${def.name}': must be kebab-case`);
  }

  if (!def.states || typeof def.states !== "object" || Object.keys(def.states).length === 0) {
    errors.push("Workflow must define at least one state in 'states'");
    return { valid: false, errors };
  }

  const stateIds = new Set(Object.keys(def.states));

  if (!def.initial || typeof def.initial !== "string") {
    errors.push("Workflow must declare an 'initial' state name");
  } else if (!stateIds.has(def.initial)) {
    errors.push(`Initial state '${def.initial}' is not declared in 'states'`);
  }

  let hasTerminal = false;

  for (const [stateId, state] of Object.entries(def.states)) {
    if (!state || typeof state !== "object") {
      errors.push(`State '${stateId}' must be an object`);
      continue;
    }

    if (state.terminal) {
      hasTerminal = true;
      if (state.transitions && state.transitions.length > 0) {
        errors.push(`Terminal state '${stateId}' must not define outgoing transitions`);
      }
      continue;
    }

    // Child invocation validation
    if (state.invoke) {
      if (!state.invoke.workflow || typeof state.invoke.workflow !== "string") {
        errors.push(`State '${stateId}' has an invoke block missing 'workflow' name`);
      }
    }

    // Subagent delegation validation
    if (state.subagent) {
      if (typeof state.subagent === "string") {
        if (!state.subagent.trim()) {
          errors.push(`State '${stateId}' has empty 'subagent' name`);
        }
      } else if (typeof state.subagent === "object" && state.subagent !== null) {
        if (!state.subagent.agent || typeof state.subagent.agent !== "string" || !state.subagent.agent.trim()) {
          errors.push(`State '${stateId}' has 'subagent' object missing required 'agent' name`);
        }
      } else {
        errors.push(`State '${stateId}' 'subagent' must be a string or object`);
      }
    }

    // Non-terminal state must have transitions
    if (!state.transitions || !Array.isArray(state.transitions) || state.transitions.length === 0) {
      errors.push(`Non-terminal state '${stateId}' has no transitions defined`);
      continue;
    }

    const seenOutcomes = new Set<string>();

    for (let i = 0; i < state.transitions.length; i++) {
      const tr = state.transitions[i];
      if (!tr || typeof tr !== "object") {
        errors.push(`State '${stateId}' transition #${i + 1} must be an object`);
        continue;
      }

      if (!tr.to || typeof tr.to !== "string") {
        errors.push(`State '${stateId}' transition #${i + 1} is missing a 'to' target state`);
      } else if (!stateIds.has(tr.to)) {
        errors.push(`State '${stateId}' transition #${i + 1} targets unknown state '${tr.to}'`);
      }

      if (tr.outcome) {
        if (typeof tr.outcome !== "string") {
          errors.push(`State '${stateId}' transition #${i + 1} outcome must be a string`);
        } else if (seenOutcomes.has(tr.outcome)) {
          errors.push(`State '${stateId}' has duplicate transition outcome '${tr.outcome}'`);
        } else {
          seenOutcomes.add(tr.outcome);
        }
      }

      if (tr.max_retries !== undefined && (!Number.isInteger(tr.max_retries) || tr.max_retries < 1)) {
        errors.push(`State '${stateId}' transition #${i + 1} max_retries must be an integer >= 1`);
      }
    }
  }

  if (!hasTerminal) {
    errors.push("Workflow must define at least one terminal state ('terminal: true')");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}
