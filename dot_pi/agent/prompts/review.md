---
description: Review code or changes using the merge-review workflow and software-engineering skill
argument-hint: "[target or base_branch] [-- extra focus areas]"
---
Execute a code review using the `merge-review` workflow (from the `pi-workflow-executor` package) and the software-engineering skill mindset.

1. **Activate Skills and Start the Workflow**:
   - Load the `software-engineering` skill (`skills/sw-engineer/SKILL.md`).
   - The `merge-review` workflow is provided by the `pi-workflow-executor` package; there is no `workflow-executor` skill to load. Start it with `workflow_start({ workflow: "merge-review", task: "<slug>", prompt: "..." })` and read the definition path the tool returns.

2. **Determine Review Scope**:
   - Target change: If a branch, PR, or commit range is provided in `${@:-}`, use it. Otherwise, default to the current branch (`HEAD`).
   - Base branch: Default to `${1:-main}` unless specified otherwise.
   - Task slug: Derive a kebab-case slug identifying this review (e.g. from the branch name or target, e.g. `review-<branch-name>`).
   - Additional focus areas: If the user supplied extra areas to scrutinize (e.g. `-- concurrency, public API stability, logging`), treat them as first-class review criteria. Record them in `reviews/{task}/scope.md` alongside the default criteria, and ensure the `assess` state explicitly reports on each one. User-supplied focus areas: ${@:-none}.

3. **Execute the `merge-review` Workflow**:
   - Follow the state machine in the definition path returned by `workflow_start` (bundled as `merge-review/merge-review.yaml`). It defines the states, transitions, artifacts, and the exact git commands;

4. **Neovim MCP Integration**:
   - If `nvim-editor-mcp` is available:
     - When findings are compiled in `assess`/`triage`, populate Neovim's quickfix list using `mcp__nvim_editor_mcp__set_quickfix` with `{ path, line, col, text }` for each finding so they are immediately navigable in Neovim.
     - Send a completion notification to Neovim using `mcp__nvim_editor_mcp__notify`.
   - For ad-hoc reviews of an open buffer/selection without a git diff, inspect via `mcp__nvim_editor_mcp__nvim_exec_lua`, evaluate against senior software engineering standards and any user-supplied focus areas, and populate the quickfix list.
