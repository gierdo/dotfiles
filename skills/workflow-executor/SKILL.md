---
name: workflow-executor
description: "Execute a multi-step task workflow defined as a declarative state machine with refinement loops. Use when the user asks to run, start, or follow a named workflow (e.g. feature-implementation). Read available workflows with 'ls <this-skill-dir>/workflows/'"
---

# Workflow executor

You execute task workflows defined as declarative state machines. A workflow is
not a linear checklist: states loop back to earlier states when a later state
uncovers a gap the earlier one should have closed (e.g. planning reveals a
missing requirement, so it loops back to specification).

This skill is harness-neutral. It is the adapter: you read the workflow
definition, determine the current state from artifacts on disk, pursue that
state's goal, and follow the first matching transition. The YAML is the source
of truth; you supply the judgment.

## Locate the workflow definitions

Workflows live under `<this-skill-dir>/workflows/<name>/<name>.yaml`. Read the
requested workflow's YAML before doing anything else. If the named workflow is
not present, list `workflows/` and stop.

## The definition format

- `inputs` - parameters beyond `task`. `task` is always required: a kebab-case
  slug (`[a-z0-9-]+`) that namespaces the run's artifacts. Use the user's; else
  propose one from the request and confirm it. Never change it mid-run: that
  orphans the artifacts.
- `artifacts` - files on disk that hold state. Paths may contain `{input}`
  references. Never track progress only in memory. The orchestrator may
  override any artifact path; then write there and report the real path. A
  path like `<changeRoot>/...` is resolved at runtime, not substituted; see
  "OpenSpec-backed workflows".
- `log` - the artifact every workflow declares: an append-only record of each
  state entry/exit and the transition taken, with a one-line reason. It is the
  audit trail and loop counter. Until its directory exists, keep notes in the
  conversation and write them once it does.
- `initial` - the starting state.
- `states` - each has a `goal`, optional `consumes`/`produces` artifacts, an
  `exit_gate`, and an ordered `transitions` list of `{ when, to, reason }`. A
  state with `terminal: true` ends the run. A state with `invoke` runs another
  workflow; see "Sub-workflows".
- `herdr` - optional; see "Herdr".

`exit_gate` and `when` are natural-language predicates. Judge them by
inspecting the artifacts and workspace, not by running code.

## Execute

1. **Resolve inputs.** Get the `task` slug and any other required inputs.
2. **Determine the current state.** Do not assume `initial`. If the log exists,
   the state entered on its last line is current. Cross-check: if a `produces`
   artifact for that state is missing or clearly stale, the previous run did
   not finish it, so re-enter it and note the discrepancy in the log. No log
   and no artifacts means `initial`. This is what makes loops and handoffs
   between sessions or harnesses work.
3. **Announce the state** and its `goal` in one line.
4. **Pursue the goal.** Read `consumes`, write `produces`. Stay within the
   state's scope; a gap belonging to an earlier state is a loop, not a reason
   to improvise.
5. **Evaluate transitions** top to bottom and follow the FIRST whose `when`
   holds. Order matters: when conditions overlap, the earlier, narrower one
   wins by design. Take backward transitions honestly when they hold.
6. **Log the transition**: state left, state entered, `reason`.
7. **Repeat** until a `terminal` state is reached. Report completion.

## Sub-workflows

A state with an `invoke` block runs another workflow as a unit:

```yaml
state_name:
  invoke:
    workflow: debug                      # a directory under workflows/
    inputs: { require_openspec: true }   # extra child inputs; task is passed through
    entry: diagnose                      # optional child start state (default: its initial)
  transitions:
    - when: "child ended in done"
      to: next_state
    - when: "child ended in abort"
      to: other_state
```

- Execute the child's YAML with this same procedure. It has its own states,
  gates, and log; the parent is paused meanwhile. Its `task` is the parent's,
  verbatim.
- The child's terminal state is the invoke state's result; match it in the
  parent's `transitions`. An unmatched terminal state is a stuck condition:
  report it, do not guess.
- The parent consumes the child's artifacts as files. A child never advances
  the parent or edits its artifacts.
- Re-entry. A transition INTO an invoke state may carry `entry` (the child
  state to resume at, overriding the invoke block). Its `reason` is passed to
  the child, which reads its existing artifacts and log and revises them in
  place rather than starting over.
- Resume: the parent's log says you are inside the invoke state; the child's
  log gives its current state. The parent logs entering and leaving the invoke
  state with the child's terminal state.
- Re-entries of an invoke state count toward the thrash guard in the parent's
  log.

## OpenSpec-backed workflows

States that name an `openspec-*` skill (bug-fix, feature-implementation) follow
these shared conventions instead of repeating them:

- `{task}` is also the OpenSpec change name, passed verbatim as `--change
  "<task>"`.
- Drive the named skill for the state: `openspec-explore` (optional thinking),
  `openspec-propose` (create the change and every apply-required artifact),
  `openspec-update-change` (revise existing planning artifacts; never edits
  code), `openspec-apply-change` (implement `tasks.md`),
  `openspec-archive-change` (sync, then archive), `openspec-sync-specs` (only
  to sync without archiving). The skills own artifact creation, CLI calls,
  store selection, the project/root check (`openspec list --json` must show a
  non-null `root`; if the skill says the user must decide, that is a blocker),
  and the planning boundary. Never hand-create, hand-path, or edit OpenSpec
  artifacts outside the matching skill.
- Resolve `<changeRoot>` and artifact paths from `openspec status --change
  "<task>" --json`. Default paths shown in a workflow are the spec-driven
  schema's, for orientation; the CLI output wins. Workflow-owned artifacts (log
  and others like repro or review) live in the change root so they archive with
  it.
- "Apply-required set done/skipped" means every artifact in the status JSON
  reachable through `requires`, not just `applyRequires`. Delta specs may be
  skipped only when the schema's conditional/skip rules allow it.
- "All tasks complete" means `openspec instructions apply --change "<task>"
  --json` reports N/N. Mechanical verification also runs `openspec validate
  --change "<task>"` with no errors or warnings.
- Resume: the log gives the state and loop count; `openspec status` (artifact
  completeness) and `openspec instructions apply` (task progress) are
  authoritative for the rest. No change yet means you are before the
  planning/propose state. Trust disk over memory.
- Integration lands the work per the repository's conventions (commit and/or
  PR, docs/changelog, clean up temporary artifacts), then archives the change
  with `openspec-archive-change`. Do not push to protected branches or do
  anything destructive without explicit user confirmation.

## Rules

- State lives in artifact files, never only in your context. Reconstruct it
  from disk before acting.
- Do not expand a state's scope, and do not run a later state's work before its
  predecessor's exit gate holds.
- A gate you cannot judge is not passed. If it depends on signal you cannot
  obtain (build or tests will not run, a criterion is not observable), say
  what is blocking, record it in the log, and surface it. Do not pass it by
  assumption.
- Loop thrash guard. Before taking a backward transition, scan the log for the
  same loop already taken. If a state was re-entered for the same reason twice
  without progress, stop and ask the user instead of a third time.

## Herdr

If a workflow has a `herdr` block and you are running inside Herdr, you may map
`suggested_panes` to panes (advisory; the state machine stays the source of
truth). See the `herdr` skill for pane control.

When you launch an agent for a state (in Herdr or otherwise), pass it the
workflow YAML, the `task` slug, the active state, and, for OpenSpec-backed
states, the skill the state names. The agent reads this skill and the YAML, stays within its assigned state and role, and reports to
you. Only the orchestrator evaluates gates and transitions.

Detecting Herdr: do not gate solely on `HERDR_ENV=1`. Some hosts (e.g. nvim
launching an agent inside CodeCompanion) blank `HERDR_ENV` and `HERDR_PANE_ID`
even though the session is Herdr-managed. Treat yourself as inside Herdr when
`HERDR_WORKSPACE_ID` and `HERDR_SOCKET_PATH` are set and `herdr status`
succeeds. Then derive your own pane id from the surviving vars rather than
relying on `HERDR_PANE_ID` or `--current`; see the `herdr` skill.
