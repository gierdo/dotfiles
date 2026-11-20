---
name: workflow-executor
description: "Execute a multi-step task workflow defined as a declarative state machine with refinement loops. Use when the user asks to run, start, resume, or follow a named workflow (e.g. feature-implementation). Read available workflows with 'ls <this-skill-dir>/workflows/'"
---

# Workflow executor

You execute task workflows defined as declarative state machines. A workflow is
not a linear checklist: states loop back to earlier states when a later state
uncovers a gap the earlier one should have closed (e.g. planning reveals a
missing requirement, so it loops back to specification).

This skill is harness-neutral. You are the orchestrator: own the run's state,
coordinate agents and user decisions, judge gates, and take transitions. The
YAML defines the state machine; the journal and artifacts record the run.

## Locate the workflow definitions

Workflows live under `<this-skill-dir>/workflows/<name>/<name>.yaml`. Read the
requested workflow's YAML before doing anything else. If the named workflow is
not present, list `workflows/` and stop.

## The definition format

Workflows are defined in YAML. The schema supports both classic natural-language
agent orchestration and machine-enforced execution via the transition runner.

### Compatibility with classic agent orchestration

The schema is **100% backward compatible** with the classic agent mindset:

- All transitions retain their natural-language `when` predicates, `to` targets,
  and `reason` explanations. An agent executing without the runner continues to
  evaluate `when` top-to-bottom and commit transitions to the log.
- New fields (`outcome`, `requires_approval`, `max_retries`) are purely additive:
  - `outcome` provides a stable token for tool-based transition submission.
  - `requires_approval: true` formalizes the skill's existing "do not skip required
    user confirmation" rule.
  - `max_retries` formalizes the skill's existing "loop thrash guard" rule.

### Schema specification

#### Workflow (Root)

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `name` | string | Yes | Kebab-case identifier matching the directory name (`[a-z0-9-]+`). |
| `version` | int / string | No | Workflow schema or definition version. |
| `description` | string | No | High-level summary of intent, scope, and invariants. |
| `inputs` | map | No | Input parameters. `task` is always required (`[a-z0-9-]+`). |
| `artifacts` | map | No | Output/intermediate files. Supports `{task}` and `{input}` placeholders. |
| `log` | map | No | Append-only Markdown journal declaration (`path`, `description`). |
| `initial` | string | Yes | ID of the initial starting state (must exist in `states`). |
| `states` | map | Yes | State definitions dictionary keyed by state ID. |
| `herdr` | map | No | Optional Herdr multiplexer layout hints (`suggested_panes`). |

#### State Definition

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `goal` | string | No | Plain-text goal and scope boundary for the state. |
| `consumes` | string[] | No | Artifacts read during this state. |
| `produces` | string[] | No | Artifacts written during this state. |
| `exit_gate` | string | No | Natural-language predicate that must hold before forward transition. |
| `terminal` | boolean | No | If `true`, ends the run (`completed`/`aborted`). No outgoing transitions. |
| `invoke` | object | No | Sub-workflow block: `{ workflow: string, inputs?: map, entry?: string }`. |
| `subagent` | string / object | No | Indicates this state should be handed over to a named subagent (e.g. `reviewer`, `worker`, `scout`). |
| `transitions` | object[] | Yes* | List of transition rules (*required for all non-terminal states). |

#### Transition Definition

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `outcome` | string | Yes* | Unique token for this transition branch (*required for transition runner). |
| `when` | string | No | Natural-language condition or trigger for this transition. |
| `to` | string | Yes | Target state ID (must exist in `states`). |
| `reason` | string | No | Descriptive reason committed to logs and shown in approval prompts. |
| `requires_approval` | boolean | No | If `true`, pauses run and requires user confirmation before advancing. |
| `max_retries` | integer | No | Maximum consecutive loop entries before thrash guard halts the run. |
| `entry` | string | No | Child entry state override when transitioning into an invoked state. |

`exit_gate` and `when` are natural-language predicates. Judge them by
inspecting the artifacts and workspace, not by running code.

## Transition runner integration

When running under Pi with the transition runner extension:

- The slash command `/workflow <name> [task] [instructions]` starts or resumes runs.
  Running `/workflow` with no args (or `/workflow list`) opens an interactive
  selector listing all active, paused, and finished runs, allowing direct resumption.
- The transition runner stores authoritative state in `.workflow/state.db` (SQLite).
- Agents advance state by calling the `workflow_transition` tool with `runId`, `outcomeId`,
  `expectedRevision`, and optional `evidence`.
- Gated transitions marked with `requires_approval: true` pause automatically and prompt the
  user through an interactive dialog (`ctx.ui.select`) with 3 options:
  1. Approve transition
  2. Reject transition
  3. Chat about it (ask question / discuss; agent answers in chat and re-presents the dialog).
  The agent cannot bypass or self-approve.
- Refinement loops are bounded by `max_retries` (default 2) to halt thrashing.
- The Markdown journal (`.workflow/runs/<workflow>/{task}/workflow-log.md`) is synchronized
  automatically as a one-way read-only projection from SQLite.

## Execute

1. **Identify the run.** Use the project, workflow name, and `task` slug to
   locate the journal. Recover inputs and overrides on resume; confirm only
   what is missing or conflicts with the request.
2. **Initialize or resume** as described below. Announce the active state and
   its goal in one line.
3. **Pursue the goal.** Read `consumes`, write `produces`, and delegate as
   useful. Stay within scope and persist results before judging gates.
4. **Evaluate transitions** top to bottom. Follow the first matching `when`.
   Require the exit gate for normal progress; explicit failure, abort, or
   refinement transitions may handle an unmet gate. If none matches, record
   the blocker and pause. Do not skip required user confirmation.
5. **Commit the transition to the journal** as one record: state left, state
   entered, and `reason`. Do this before starting the next state. At a terminal
   state, persist its outcome. Report journal and result paths on pause or exit.

## Persistence and resume (every workflow)

- Create the journal directory and record the initial entry before work or
  dispatch, even if no deliverable exists yet. Record workflow name/version,
  task, request context, non-secret inputs, project/worktree, and any path
  overrides. If the journal path is overridden, leave a pointer at its default
  location so the run can still be found. Append updates as locations become
  known. Keep secrets out of workflow records; do not commit them by default.
- Save substantive results to declared artifacts as work progresses. When a
  state has no output artifact yet, record its findings, decisions, and checks
  in the journal or a file linked from it. Before yielding, record what is
  complete and pending, including failed or skipped checks and the exact
  question or blocker. Record user decisions before advancing. Chat and agent
  messages are not the system of record.
- Resume from the last recorded entry or transition, not the last line (which
  may be a checkpoint). Read the journal, relevant artifacts, and workspace.
  Missing or stale current-state results mean unfinished work, not a reset;
  continue from the last verified checkpoint. Honor pending approvals and
  reuse a recorded terminal outcome. Before retrying interrupted side effects,
  check whether they already happened.
- Start at `initial` only for a new run.
- If you cannot persist state, stop and report
  the blocker.

## Orchestrate and delegate

- When a state declares `subagent: <name>` (or `{ agent: <name>, ... }`), the
  orchestrator MUST hand over that state's work to the declared subagent (e.g.
  `reviewer`, `scout`, `worker`) via the `subagent` tool or Herdr.
- Pass the subagent its active state, scoped goal, inputs, consumes/produces
  artifact paths, and applicable skills.
- The subagent performs the state's work and writes deliverables to the declared
  artifact paths.
- The orchestrator inspects the subagent's delivered artifacts and evidence,
  evaluates the state's exit gate, and commits the state transition via
  `workflow_transition`. Subagents never commit transitions or approve gates
  directly; the orchestrator retains authoritative process control.
- For states without `subagent`, decide per state whether to work directly or
  dispatch subagents. Keep user decisions and small or tightly coupled work
  with the orchestrator.
- Give each agent the workflow YAML and executor skill, task slug, active
  state, scoped goal, inputs, artifact paths, allowed writes, and applicable
  skills. Give parallel writers disjoint outputs and isolate workspace changes
  that could interfere. Do not dispatch later-state work prematurely.
- Log assignments and output paths. Have agents save findings or evidence to
  their assigned files; inspect and incorporate the results before advancing.
  On resume, reconcile outstanding assignments with saved outputs before
  retrying. Only the orchestrator updates the run journal, judges gates,
  takes transitions, and reports the run's outcome.

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
- Before dispatch, record the child's journal path and entry override in the
  parent journal. Follow the child journal on resume; reuse a terminal outcome
  from the same invocation. Apply explicit re-entry once per invocation, not
  once per session. Record the child's outcome before the parent transitions.
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
  schema's, for orientation; the CLI output wins. Deliverables like repro or
  review live in the change root so they archive with it. Keep the journal at
  its stable project path before creation and after archive; record the change
  and archive paths there. When resuming a legacy `<changeRoot>/workflow-log.md`,
  preserve its history in the stable journal before continuing.
- "Apply-required set done/skipped" means every artifact in the status JSON
  reachable through `requires`, not just `applyRequires`. Delta specs may be
  skipped only when the schema's conditional/skip rules allow it.
- "All tasks complete" means `openspec instructions apply --change "<task>"
  --json` reports N/N. Mechanical verification also runs `openspec validate
  --change "<task>"` with no errors or warnings.
- Resume: the log gives the state and loop count; `openspec status` (artifact
  completeness) and `openspec instructions apply` (task progress) are
  authoritative for active change progress. If the change is no longer active,
  check for an archived change before deciding what remains.
- Integration lands the work per the repository's conventions (commit and/or
  PR, docs/changelog, clean up temporary artifacts), then archives the change
  with `openspec-archive-change`. Do not push to protected branches or do
  anything destructive without explicit user confirmation.

## Rules

- Do not expand a state's scope or do work for a state before entering it.
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

Detecting Herdr: do not gate solely on `HERDR_ENV=1`. Some hosts (e.g. nvim
launching an agent inside CodeCompanion) blank `HERDR_ENV` and `HERDR_PANE_ID`
even though the session is Herdr-managed. Treat yourself as inside Herdr when
`HERDR_WORKSPACE_ID` and `HERDR_SOCKET_PATH` are set and `herdr status`
succeeds. Then derive your own pane id from the surviving vars rather than
relying on `HERDR_PANE_ID` or `--current`; see the `herdr` skill.
