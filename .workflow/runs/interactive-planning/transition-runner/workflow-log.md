# Interactive planning: transition-runner

- Workflow: `interactive-planning`, version 1
- Input: `task=transition-runner` (confirmed by user)
- Project/worktree: `/home/mn-man.biz/h2547/.local/share/chezmoi`
- Request: Plan implementation of a transition runner for the workflow executor. Do not implement in this run.
- Artifact overrides: none. Plan: `.workflow/plans/transition-runner/plan.md`.

## Entered `investigate`

Goal: Confirm the existing execution boundary, tooling, and whether this project uses OpenSpec.

### Investigation checkpoint

- `/workflow` is a TypeScript Pi extension that discovers YAML definitions and forwards a prompt. The skill and agent currently own gates, transitions, and Markdown journal recovery.
- No OpenSpec directory or workflow-specific test setup was found in the chezmoi checkout. Node v26.13.0 is available locally; the supported runtime for a runner is not yet decided.
- Pending user question: Is the existing chezmoi/Pi workflow setup the right target for the plan?
- Status: paused in `investigate` awaiting response; no transition or implementation.

### User decision

Confirmed the existing chezmoi/Pi workflow setup as the target for now.

## Transition: `investigate` -> `clarify_intent`

Reason: oriented; reverse-engineer the request.

### Intent checkpoint

- Plan a small local runner for the existing `/workflow` setup. The runner validates declared transitions, enforces recorded requirements such as approvals, and resumes from persisted state. Agents still do the work and judge qualitative outcomes; the runner should not infer them from prose.
- Keep the first cut focused on validation and deterministic advancement. Automatic agent dispatch, migrating all eight definitions, and adopting a separate orchestration platform are out of scope for the first cut. This run produces a plan, not code.
- Top priority: interrupted runs resume from the last committed state without guessing or bypassing gates.
- Status: paused in `clarify_intent`. Pending question: does this capture the intended first version?

### User decision

Confirmed the v1 intent and exclusions.

## Transition: `clarify_intent` -> `requirements`

Reason: intent confirmed; clarify genuine ambiguity.

### Requirements checkpoint

- Proposed v1 coverage: use the runner for new `code-reconnaissance` runs; keep other workflows and existing Markdown-only runs on the current executor. Do not infer transition or approval history from Markdown.
- For runner-managed runs, resume from committed state; if the definition changed or an interruption left an external action unverified, pause rather than guess or retry it automatically.
- Status: paused in `requirements`. Pending question: is it acceptable to leave existing runs on the old executor, or must v1 import them?

### User decision

V1 must work with all eight current workflows, not just the proposed pilot. Existing runs do not need to be migrated; breaking compatibility is acceptable.

## Transition: `requirements` -> `clarify_intent`

Reason: refinement; full workflow coverage expands the previously confirmed v1 scope.

### Revised intent checkpoint

- New runs of all eight shipped workflows use the deterministic runner. Convert their definitions as needed, preserving workflow behavior such as refinement loops, approval pauses, and child workflow re-entry.
- No legacy run migration or compatibility layer is required. Agents still perform state work and judge qualitative outcomes. Automatic dispatch and a separate orchestration platform remain out of scope.
- Status: paused in `clarify_intent`. Pending question: does the revised v1 boundary match the request?

### User decision

Confirmed the revised v1 scope: all eight workflows, no legacy migration, no automatic dispatch.

## Transition: `clarify_intent` -> `requirements`

Reason: revised intent confirmed; resolve approval behavior.

### Requirements checkpoint (re-entry)

- V1 may replace the definition and journal formats. No existing run import is required. Support new runs of all shipped workflows, including nested debug re-entry and interactive pauses.
- Resume must fail closed on an incompatible definition change or an unresolved interrupted side effect.
- Proposed approval requirement: a gated transition requires an explicit, recorded user action tied to the pending run and gate. An agent's assertion that the user approved is insufficient. Whether the UI uses a command or confirmation control is a design decision.
- Status: paused in `requirements`. Pending question: require an explicit approval action, or must ordinary chat replies such as `yes` be enough?

### User decision

Explicit approval action required; ordinary chat replies do not count. UI choice deferred to design.

## Transition: `requirements` -> `effort_and_isc`

Reason: requirements clear enough; set effort and define done.

### Effort and Ideal State Criteria checkpoint

Proposed effort: reliable local MVP. Use automated schema and transition tests, scripted workflow scenarios for all eight definitions, fault-injection for resume, and a targeted Pi smoke test. Document how to start, pause, approve, and resume; explicitly note the legacy format break.

1. An invalid workflow definition is rejected before a run starts.
2. Each of the eight shipped workflows reaches its expected terminal outcome in a scripted scenario.
3. An unknown outcome pauses without advancing state.
4. A gated transition rejects an advance without explicit user approval for that pending gate.
5. A stale approval cannot authorize a subsequent visit to the same gate.
6. Resume after a simulated interruption restores the last committed state.
7. Resume pauses on a workflow definition mismatch.
8. Resume does not automatically retry an unresolved external action.
9. A refinement loop pauses at its configured limit.
10. Child abort is distinguishable from success.
11. Child re-entry is applied once per invocation, even across resume.

Status: paused in `effort_and_isc`. Pending question: does this test bar define done, or is something missing or out of scope?

### User decision

Accepted the proposed local MVP and test bar; requested proceeding.

## Transition: `effort_and_isc` -> `explore_approaches`

Reason: done is defined; explore how to build it.

### Approaches checkpoint

- Recommended: testable TypeScript runner module plus a thin Pi adapter. The module owns validation, transitions, and persistence without Pi dependencies. Pi's supported command, tool, and confirmation APIs provide user and agent entry points. No standalone CLI required for v1.
- Alternative: put all logic in the existing Pi extension. Fewer modules initially, but state-machine, failure, and resume tests become more coupled to Pi.
- Alternative: standalone CLI plus Pi adapter. Useful for non-Pi hosts and shell use, but adds packaging and extra care to ensure the agent-facing interface cannot approve gates.
- Status: paused in `explore_approaches`. Pending question: choose runner module plus Pi adapter, extension-only, or separate CLI?

### User decision

Chose the TypeScript runner module with a thin Pi adapter.

## Transition: `explore_approaches` -> `validate_design`

Reason: an approach is chosen; validate the design.

### Design checkpoint: architecture

- Definitions supply structured outcome IDs, transition targets, optional approval requirements, retry limits, and typed child invocation rules; prose goals and evidence guidance stay for the agent. Migrate all eight definitions and validate before dispatching work.
- The runner owns the sole authoritative structured record, including current state, invocation, definition fingerprint, pending gate, and revision. It commits permitted transitions before the next state's work. A readable journal is derived, not used to infer state. Stale submissions are rejected against the expected revision.
- The agent does state work and submits outcome IDs and evidence references through the Pi adapter. Pi's user-facing confirmation path is the only supported way to record approval; approvals bind to the specific pending gate visit. This governs workflow advancement, not arbitrary shell/filesystem access.
- `/workflow` remains the entry point. The adapter hands the agent the current state, does not dispatch subagents automatically, and reports terminal or paused outcomes. Missing checks, stale approvals, and uncertain external side effects cannot silently advance the run.
- Status: paused in `validate_design`, architecture section. Pending question: does this separation of responsibilities work?

### User decision

Approved the architecture split and asked to proceed.

### Design checkpoint: persistence and run lifecycle

- Proposed one SQLite database per checkout under `.workflow/`, accessed via `node:sqlite` (verified on the local Node 26 runtime; test in the launched Pi runtime before committing to it). Use transactions plus expected revisions to commit one transition, approval, or side-effect record at a time. Generate the Markdown view from structured records.
- Pi starts or resumes an explicitly identified run. On submission, the runner validates the definition fingerprint, active state visit, outcome ID, evidence references as required by the transition, and revision. Unknown outcomes pause; stale submissions cannot update the record.
- A gated submission creates a pending approval. The Pi adapter shows run, gate, and intended action to the user. Store the decision against that specific pending submission; an approval cannot transfer to a later visit or a changed submission.
- Store child invocations under the parent run, giving each re-entry a fresh invocation ID. Resume the recorded active invocation rather than applying the entry override again. Count refinement retries by transition ID and pause at the configured cap.
- For declared external actions, persist intent before execution and confirmation after it. If interrupted between those events, pause for user reconciliation rather than retrying. SQLite protects state updates, not external effects.
- Status: paused in `validate_design`, persistence and run lifecycle section. Pending question: is SQLite plus explicit reconciliation acceptable for v1?

### User decision

Approved SQLite persistence and explicit reconciliation for interrupted external actions.

## Transition: `validate_design` -> `premortem`

Reason: architecture and lifecycle validated; stress-test before writing the plan.

### Premortem checkpoint

Load-bearing assumptions:
- Pi's installed runtime and chezmoi deployment load the runner, YAML parser, and `node:sqlite`. If not, the command cannot start. Mitigate with an installed-runtime smoke test before schema migration.
- Structured outcomes capture behavior across all eight workflows. If not, a valid graph can still route work incorrectly. Mitigate with a transition inventory and scripted failure/refinement paths, not only happy paths.
- Workflow approval is a process control, not a sandbox for an agent that can write local files or execute commands. Accept this boundary for v1; only the Pi user-facing path may record an approval through supported interfaces.

Failure modes and proposed mitigations:
- Concurrent or late replies advance the wrong state: check the revision and bind approval to one pending submission.
- Re-entry reruns the child or consumes an old result: require an invocation ID; test interruption before and after the child outcome is recorded.
- A remote action succeeds just before Pi exits: persist intent first, then pause for reconciliation on resume if no result was committed.
- An edited definition silently changes a resumed route: verify fingerprints for the parent and invoked definitions before advancing.

Status: paused in `premortem`. Pending question: adopt these mitigations and accept the local trust boundary for v1?

### User decision

Requested writing the plan with the proposed mitigations and trust boundary.

## Transition: `premortem` -> `write_plan`

Reason: risks resolved; write the plan.

### Plan checkpoint

- Written: `.workflow/plans/transition-runner/plan.md`.
- Contains agreed scope, architecture, persistence, approval and reconciliation behavior, verification criteria, and mitigations. Worker-ready tasks are not yet written.
- Status: paused in `write_plan`. Pending question: approve the written plan as-is for task breakdown, or request changes?
