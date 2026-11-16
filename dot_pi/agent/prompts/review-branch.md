---
description: Review current branch against merge base using merge-review workflow
argument-hint: "[base_branch]"
---
Execute a branch review against the merge base with `${1:-main}` using the `workflow-executor` skill and the `merge-review` workflow, applying the `software-engineering` skill mindset.

1. **Activate Skills**:
   - Load the `workflow-executor` skill (`/home/dominik/.pi/agent/skills/workflow-executor/SKILL.md`).
   - Load the `software-engineering` skill (`/home/dominik/.pi/agent/skills/sw-engineer/SKILL.md`) alongside it.

2. **Workflow Inputs**:
   - `base_branch`: `${1:-main}`.
   - `target`: Current branch (`HEAD`).
   - `task`: Kebab-case slug derived from current branch (e.g. `branch-review-$(git rev-parse --abbrev-ref HEAD | tr '/' '-')`).

3. **Execute `merge-review` State Machine**:
   - Follow `/home/dominik/.pi/agent/skills/workflow-executor/workflows/merge-review/merge-review.yaml`.
   - Maintain artifacts in `reviews/{task}/`:
     - `reviews/{task}/scope.md`: Record resolved merge-base SHA (`git merge-base origin/{base_branch} HEAD`), diff command (`git diff origin/{base_branch}...HEAD`), and review scope.
     - `reviews/{task}/findings.md`: Document actionable findings grouped by severity (blocker, major, minor, nit) with concrete locations and suggested directions.
     - `reviews/{task}/workflow-log.md`: Log all state entries, exits, and transition reasons.
   - Proceed through states: `scope` -> `understand` -> `assess` -> `triage` -> `deliver` -> `done`.
   - Apply skeptical senior criteria: logic errors, edge cases, missing error handling, YAGNI/complexity, security boundaries, performance.

4. **Neovim MCP Integration**:
   - If `nvim-editor-mcp` is connected:
     - Populate Neovim's quickfix list with findings via `mcp__nvim_editor_mcp__set_quickfix`.
     - Notify Neovim of review delivery and final verdict via `mcp__nvim_editor_mcp__notify`.
