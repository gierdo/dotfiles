export interface InputDefinition {
  description?: string;
  required?: boolean;
  default?: unknown;
}

export interface ArtifactDefinition {
  path: string;
  description?: string;
}

export interface ChildInvocationDefinition {
  workflow: string;
  inputs?: Record<string, unknown>;
  entry?: string;
}

export interface TransitionDefinition {
  outcome?: string;
  when?: string;
  to: string;
  reason?: string;
  requires_approval?: boolean;
  max_retries?: number;
}

export interface SubagentDefinition {
  agent: string;
  skills?: string;
  task?: string;
}

export interface StateDefinition {
  goal?: string;
  consumes?: string[];
  produces?: string[];
  exit_gate?: string;
  terminal?: boolean;
  invoke?: ChildInvocationDefinition;
  subagent?: string | SubagentDefinition;
  transitions?: TransitionDefinition[];
}

export interface WorkflowDefinition {
  name: string;
  version?: number | string;
  description?: string;
  inputs?: Record<string, InputDefinition>;
  artifacts?: Record<string, ArtifactDefinition>;
  initial: string;
  states: Record<string, StateDefinition>;
  herdr?: unknown;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

export type RunStatus = "active" | "paused" | "completed" | "aborted";

export interface RunRecord {
  id: string;
  task: string;
  workflow: string;
  current_state: string;
  revision: number;
  definition_fingerprint: string;
  status: RunStatus;
  pause_reason?: string;
  created_at: string;
  updated_at: string;
}

export interface StateVisitRecord {
  id: number;
  run_id: string;
  state_id: string;
  visit_index: number;
  entered_at: string;
  exited_at?: string;
}

export interface TransitionInput {
  runId: string;
  outcomeId: string;
  expectedRevision: number;
  evidence?: string[];
}

export interface TransitionResult {
  status: "advanced" | "pending_approval" | "paused" | "terminal";
  nextState?: string;
  gate?: string;
  reason?: string;
  revision?: number;
}
