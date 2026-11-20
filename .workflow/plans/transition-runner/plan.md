# Transition runner implementation plan

## Intent and user story

As a Pi workflow user, I want to resume a run after an interruption without reconstructing its state from chat or Markdown. I want explicit control over approval gates while agents continue to perform the work and judge qualitative outcomes.

## Scope and quality bar

Build a reliable local MVP for new runs of the eight shipped workflows: `bug-fix`, `code-reconnaissance`, `debug`, `feature-implementation`, `interactive-planning`, `merge-review`, `refactoring`, and `task-implementation`. Convert their definitions to structured outcomes while preserving state work, review and refinement loops, user pauses, and child workflow re-entry. Correct ambiguous branches rather than preserving ambiguous behavior.

No migration of existing runs, Markdown recovery fallback, standalone CLI, new orchestration platform, or automatic agent dispatch. Agents still do state work. The runner enforces advancement through supported interfaces; it does not sandbox shell or filesystem access or independently judge the quality of agent work. Retain each workflow's existing applicable safety and tool-use constraints.

## Design and data flow

- **Definitions:** Versioned YAML declares state IDs, allowed outcome IDs and transition targets, termination outcomes, approval requirements, and bounded refinement transitions. Child invocation rules declare input mapping, entry overrides, and routes by child outcome. Keep goals and evidence guidance in prose. Reject invalid definitions, including duplicate IDs, dangling references, invalid child entries, and invalid or missing child outcome routes, before starting work. Inventory each workflow's existing routes before conversion; for example, `bug-fix` must distinguish artifact-validation failure, code failure, and blocked checks, and propagate child abort as abort rather than success.
- **Runner:** A TypeScript module without Pi dependencies owns validation, transitions, and persistence. One SQLite database per checkout under `.workflow/` stores the authoritative structured records. Record run ID, state visit, invocation ID, definition fingerprints, run revision, outcome, evidence references, approval and external-action events. A transaction checks the expected revision and commits the proposed change before exposing the next state. Generate the readable Markdown journal from these records; do not use it as a second source of truth.
- **Pi adapter:** Keep `/workflow` as the user entry point for starting or resuming an explicitly identified run. Provide agent-facing access to the active state and outcome submission. Keep approval on a user-facing Pi confirmation path separate from the agent's outcome interface. The user sees the run, gate, and proposed action; a plain chat reply does not record approval. A denial or dismissal does not advance. Bind approval to a specific pending submission and state visit; a changed submission or a later visit requires fresh approval.

### Runtime behavior

1. Validate the definition graph and record fingerprints for the workflow and its invoked definitions. Start at the declared initial state or resume from the last committed state. A fingerprint mismatch pauses the run rather than reinterpreting history.
2. The agent works in the active state and submits an allowed outcome ID, evidence references where required, and the expected revision. Unknown outcomes pause. Stale submissions leave current state unchanged.
3. If the outcome needs approval, persist the pending submission and wait for explicit Pi approval. Otherwise commit the transition immediately. Record terminal success and abort distinctly.
4. For a child workflow, commit its invocation and selected entry before child work. Associate the outcome with that invocation. Re-entry opens a new invocation; resume reuses the existing invocation instead of applying the entry override again. Count refinement retries by transition ID and pause at the configured limit.
5. For a declared external action, persist intent before execution and confirmation after it. On interruption between these records, pause for explicit reconciliation. Do not retry automatically or treat missing confirmation as evidence the action did not happen. SQLite transactions protect local state, not remote effects.

## Dependencies and verification

Use the existing Pi extension APIs, TypeScript, a YAML parser available in the installed extension environment, and `node:sqlite`. The shell's Node 26 runtime supports SQLite; the launched Pi runtime and chezmoi deployment still need a smoke test. Verify imports, a minimal schema load, and database open/write/reopen in Pi before migrating the workflow definitions. If the smoke test fails, resolve packaging or revisit the storage choice before continuing.

Use runner unit tests, scripted scenarios for all eight workflows, interruption and concurrency tests against a temporary database, and an installed Pi smoke test for explicit approval and resume. Document start, pause, approval, reconciliation, and resume. Document the format break and that legacy runs are not imported.

## Ideal state criteria

1. The runner rejects an invalid definition before a run starts.
2. A scripted scenario for each shipped workflow reaches its expected terminal outcome.
3. An unknown outcome leaves the run paused at the current state.
4. An approval-gated transition cannot advance without an explicit Pi approval for the pending submission.
5. A stale approval cannot authorize a later visit to the same gate.
6. Resume after an injected interruption restores the last committed state.
7. A definition fingerprint mismatch blocks resume.
8. An unresolved external action is not retried automatically.
9. A refinement loop pauses at its configured limit.
10. A child abort is distinguishable from success in the persisted outcome.
11. Each child invocation applies its selected entry once, including across resume.

## Risks and mitigations

| Risk | Response |
| --- | --- |
| Installed Pi cannot load SQLite or the YAML parser. | Run the installed-runtime smoke test first. Do not migrate definitions until it passes. |
| YAML conversion changes behavior despite passing validation. | Inventory routes and test representative blocked, abort, and refinement scenarios in addition to successful scripted runs. |
| Concurrent submissions or late approvals advance the wrong state. | Check the expected revision in the transaction. Bind approval to a pending submission and state visit. |
| A resumed child re-enters twice or publishes a stale result. | Require invocation IDs. Test interruption before and after the child terminal outcome is recorded. |
| An external action succeeds just before Pi exits. | Persist intent before execution. Require reconciliation if intent has no recorded result. |
| Definition edits alter a resumed run. | Verify fingerprints of both parent and child definitions. |
| An agent bypasses supported interfaces using local shell or filesystem access. | Accepted trust boundary for this MVP; document that approval is workflow control, not a sandbox. |
