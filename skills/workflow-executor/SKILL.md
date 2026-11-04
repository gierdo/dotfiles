---
name: workflow-executor
description: "Execute a multi-step task workflow defined as a declarative state machine with refinement loops. Use when the user asks to run, start, or follow a named workflow (e.g. feature-implementation). Read available workflows with 'ls <this-skill-dir>/workflows/'"
---

# Workflow executor

You execute task workflows defined as declarative state machines. A workflow is
not a linear checklist: states can loop back to earlier states when a later
state uncovers a gap the earlier one should have closed (e.g. planning reveals a
missing requirement, so it loops back to specification).

This skill is harness-neutral. It is the adapter: you read the workflow
definition, determine the current state from artifacts on disk, pursue that
state's goal, and follow the first matching transition. The YAML is the source
of truth; you supply the judgment.

## Locate the workflow definitions

Workflow definitions ship inside this skill under `workflows/`. Each workflow is
a directory containing `<name>.yaml` (the state machine).

```bash
ls "<this-skill-dir>/workflows/"
```

Read the requested workflow's YAML before doing anything else. If the user names
a workflow that is not present, list what is available and stop.

## Understand the definition

A workflow YAML defines:

- `inputs` - parameters supplied at start. Always required: a `task` slug
  (kebab-case) that namespaces this run's artifacts.
- `artifacts` - files on disk that hold state. Paths may contain `{input}`
  references (e.g. `specs/{task}/spec.md`). These files ARE the state: never
  track workflow progress only in your own memory.
- `initial` - the starting state.
- `states` - each has a `goal`, optional `consumes`/`produces` artifacts, an
  `exit_gate`, and an ordered `transitions` list of `{ when, to, reason }`. A
  state with `terminal: true` ends the run.
- optional `herdr` - advisory pane layout when running under Herdr.

## Execute

1. **Resolve inputs.** Get the `task` slug - it namespaces every artifact. If
   the user gave one, use it. If not, propose a kebab-case slug derived from
   their request and confirm it before starting. The slug must be kebab-case
   (`[a-z0-9-]+`); reject spaces, slashes, or uppercase so artifact paths stay
   predictable. Never invent a slug silently mid-run: a changed slug orphans
   the existing artifacts.

2. **Determine the current state.** Do not assume `initial`. The log artifact
   is authoritative: if it exists, the state entered on its last line is the
   current state. Then cross-check the artifacts - if a `produces` artifact for
   the recorded state is missing or clearly stale, the previous run did not
   finish that state's work, so re-enter it rather than trusting the log blindly
   and note the discrepancy in the log. A fresh run with no artifacts and no log
   starts at `initial`. This is what makes loops and handoffs between sessions
   or harnesses work.

3. **Announce the state.** Tell the user the active state and its `goal` in one
   line before working.

4. **Pursue the goal.** Do the work the active state describes. Read its
   `consumes` artifacts, write its `produces` artifacts. Stay within the state's
   scope; if the work reveals a gap belonging to an earlier state, that is a
   loop, not a reason to improvise outside the current state.

5. **Evaluate transitions.** When the state's work is done, evaluate its
   `transitions` top to bottom and follow the FIRST whose `when` condition
   holds. Order matters: when two conditions overlap (e.g. "the plan is wrong"
   vs "a requirement is wrong"), the earlier, narrower one wins by design, so
   read them in order rather than picking the one that feels closest. `when`
   and `exit_gate` are natural-language predicates: judge them by inspecting
   the artifacts and workspace, not by running code. Backward `to` targets are
   refinement loops - take them honestly when the condition holds.

6. **Log the transition.** Append one line to the workflow's `log` artifact
   (its path is declared in the workflow's `artifacts`): the state left, the
   state entered, and the transition `reason`. This is the audit trail that
   lets a later session reconstruct the run and resume deterministically.

7. **Repeat** until a `terminal` state is reached. Report completion.

## Rules

- State lives in the artifact files, never only in your context. Before acting,
  reconstruct state from disk.
- Evaluate gates by judgment against the artifacts; do not invent boolean code
  to decide them.
- Take backward transitions when their condition holds. Suppressing a needed
  refinement loop to appear linear defeats the workflow.
- Do not expand a state's scope. Loop instead of improvising across phases.
- One state is active at a time. Do not run a later state's work before its
  predecessor's exit condition holds.
- A gate you cannot judge is not a passed gate. If a gate depends on signal you
  cannot obtain (the build will not run, tests cannot execute, a criterion is
  not observable), do not pass it by assumption. Say what is blocking, record it
  in the log, and surface it to the user rather than advancing.
- Guard against loop thrash. The log is also a loop counter: before taking a
  backward transition, scan it for the same loop already taken. If a state has
  been re-entered for the same reason twice without progress, stop looping -
  the gap is not being closed by repetition. Report the stuck condition to the
  user and ask how to proceed instead of taking the loop a third time.

## Herdr (optional execution layer)

If a workflow has a `herdr` block and you are running inside Herdr, you may map
states to panes as suggested: a persistent pane running the build/test watcher
gives the implementation and validation gates live signal, and a reviewer pane
can host a review agent. The mapping is advisory; the state machine remains the
source of truth. See the `herdr` skill for pane control.

Detecting Herdr: do not gate solely on `HERDR_ENV=1`. Some hosts (e.g. nvim
launching an agent inside CodeCompanion) blank `HERDR_ENV` and `HERDR_PANE_ID`
even though the session is Herdr-managed. Treat yourself as inside Herdr when
`HERDR_WORKSPACE_ID` and `HERDR_SOCKET_PATH` are set and `herdr status`
succeeds. In that case derive your own pane id from the surviving vars rather
than relying on `HERDR_PANE_ID` or `--current`; see the `herdr` skill for how.
