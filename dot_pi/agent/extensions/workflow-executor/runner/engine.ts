import type { DatabaseSync } from "node:sqlite";
import type { WorkflowDefinition, TransitionInput, TransitionResult, RunRecord } from "./types.ts";
import { validateDefinition, computeFingerprint } from "./validator.ts";
import { checkAndIncrementLoop } from "./invocations.ts";
import {
  createRun,
  getRun,
  getActiveVisit,
  executeTransition,
  pauseRun,
  completeRun,
  createPendingApproval,
  getPendingApproval,
  resolvePendingApproval,
  type PendingApprovalRecord,
} from "./db.ts";

export function startWorkflowRun(
  db: DatabaseSync,
  def: WorkflowDefinition,
  rawYaml: string,
  task: string,
  customRunId?: string
): RunRecord {
  const val = validateDefinition(def);
  if (!val.valid) {
    throw new Error(`Invalid workflow definition: ${val.errors.join("; ")}`);
  }

  const fingerprint = computeFingerprint(rawYaml);
  const runId = customRunId ?? `${def.name}-${task}-${Date.now()}`;

  return createRun(db, {
    id: runId,
    task,
    workflow: def.name,
    initialState: def.initial,
    definitionFingerprint: fingerprint,
  });
}

export function resumeWorkflowRun(
  db: DatabaseSync,
  def: WorkflowDefinition,
  rawYaml: string,
  runId: string
): RunRecord {
  const run = getRun(db, runId);
  if (!run) {
    throw new Error(`Run '${runId}' not found`);
  }

  const currentFingerprint = computeFingerprint(rawYaml);
  if (run.definition_fingerprint !== currentFingerprint) {
    pauseRun(db, run.id, run.revision, "Definition fingerprint mismatch: definition modified since run started");
    throw new Error("Definition fingerprint mismatch: resume blocked");
  }

  return getRun(db, runId)!;
}

export function submitOutcome(
  db: DatabaseSync,
  def: WorkflowDefinition,
  input: TransitionInput
): TransitionResult {
  const run = getRun(db, input.runId);
  if (!run) {
    throw new Error(`Run '${input.runId}' not found`);
  }

  if (run.status === "completed" || run.status === "aborted") {
    return { status: "terminal", nextState: run.current_state, revision: run.revision };
  }

  if (run.revision !== input.expectedRevision) {
    throw new Error(`Revision conflict: expected ${input.expectedRevision}, found ${run.revision}`);
  }

  const currentState = def.states[run.current_state];
  if (!currentState) {
    throw new Error(`State '${run.current_state}' not found in definition`);
  }

  const matched = currentState.transitions?.find(t => t.outcome === input.outcomeId);
  if (!matched) {
    pauseRun(
      db,
      run.id,
      run.revision,
      `Unknown outcome '${input.outcomeId}' in state '${run.current_state}'`
    );
    return {
      status: "paused",
      reason: `Unknown outcome '${input.outcomeId}'`,
      revision: run.revision,
    };
  }

  const activeVisit = getActiveVisit(db, run.id);
  if (!activeVisit) {
    throw new Error(`No active state visit for run '${run.id}'`);
  }

  if (matched.max_retries !== undefined) {
    const loopKey = `${run.current_state}->${matched.to}`;
    const loopCheck = checkAndIncrementLoop(db, run.id, loopKey, matched.max_retries);
    if (!loopCheck.allowed) {
      return {
        status: "paused",
        reason: `Loop thrash guard: transition '${loopKey}' reached retry limit of ${matched.max_retries}`,
        revision: run.revision,
      };
    }
  }

  if (matched.requires_approval) {
    createPendingApproval(
      db,
      run.id,
      activeVisit.id,
      matched.to,
      run.revision,
      matched.reason
    );
    pauseRun(
      db,
      run.id,
      run.revision,
      `Waiting for approval to transition to '${matched.to}'`
    );
    return {
      status: "pending_approval",
      gate: matched.to,
      reason: matched.reason,
      revision: run.revision,
    };
  }

  const updatedRun = executeTransition(db, {
    runId: run.id,
    expectedRevision: run.revision,
    toState: matched.to,
    outcomeId: input.outcomeId,
    reason: matched.reason,
  });

  const targetState = def.states[matched.to];
  if (targetState?.terminal) {
    const termStatus = (input.outcomeId === "abort" || matched.to.includes("abort")) ? "aborted" : "completed";
    completeRun(db, updatedRun.id, updatedRun.revision, termStatus);
    return {
      status: "terminal",
      nextState: matched.to,
      reason: matched.reason,
      revision: updatedRun.revision,
    };
  }

  return {
    status: "advanced",
    nextState: matched.to,
    reason: matched.reason,
    revision: updatedRun.revision,
  };
}

export function confirmPendingApproval(
  db: DatabaseSync,
  def: WorkflowDefinition,
  runId: string,
  approvalId: number,
  approved: boolean
): TransitionResult {
  const approval = db.prepare("SELECT * FROM pending_approvals WHERE id = ?").get(approvalId) as PendingApprovalRecord | undefined;
  if (!approval || approval.run_id !== runId) {
    throw new Error(`Pending approval #${approvalId} not found for run '${runId}'`);
  }
  if (approval.status !== "pending") {
    throw new Error(`Approval #${approvalId} is not in pending status (${approval.status})`);
  }

  const run = getRun(db, runId);
  if (!run) throw new Error(`Run '${runId}' not found`);

  const activeVisit = getActiveVisit(db, runId);
  if (!activeVisit || activeVisit.id !== approval.state_visit_id || run.revision !== approval.created_revision) {
    resolvePendingApproval(db, approvalId, "rejected");
    throw new Error("Stale approval cannot authorize a different state visit or revision");
  }

  if (!approved) {
    resolvePendingApproval(db, approvalId, "rejected");
    return {
      status: "paused",
      reason: "Transition rejected by user",
      revision: run.revision,
    };
  }

  resolvePendingApproval(db, approvalId, "approved");

  const updatedRun = executeTransition(db, {
    runId: run.id,
    expectedRevision: run.revision,
    toState: approval.target_state,
    outcomeId: "approved",
    reason: approval.reason,
  });

  const targetState = def.states[approval.target_state];
  if (targetState?.terminal) {
    completeRun(db, updatedRun.id, updatedRun.revision, "completed");
    return {
      status: "terminal",
      nextState: approval.target_state,
      reason: approval.reason,
      revision: updatedRun.revision,
    };
  }

  return {
    status: "advanced",
    nextState: approval.target_state,
    reason: approval.reason,
    revision: updatedRun.revision,
  };
}
