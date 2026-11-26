---
description: Fix code issues at cursor/selection in Neovim or specified target
argument-hint: "[instructions or target]"
---
Analyze and fix code issues, applying the `software-engineering` skill mindset.

1. **Skills & Mindset**:
   - Activate the `software-engineering` skill (`skills/sw-engineer/SKILL.md`).
   - For complex bugs requiring structured reproduction, root-cause analysis, and regression testing, start the `bug-fix` workflow with `workflow_start({ workflow: "bug-fix", task: "<bug-slug>" })` and follow the definition path the tool returns. The `pi-workflow-executor` package provides it; there is no `workflow-executor` skill to load.

2. **Locate Target Code**:
   - If a target file, function, or description is specified in `${@:-}`, inspect it.
   - Otherwise, if `nvim-editor-mcp` is available:
     - Query Neovim via `nvim_exec_lua` to locate the current buffer, cursor position, or active visual selection:
       `local buf = vim.api.nvim_get_current_buf(); return { path = vim.api.nvim_buf_get_name(buf), cursor = vim.api.nvim_win_get_cursor(0), filetype = vim.bo[buf].filetype }`
     - Query diagnostics at the location using `get_diagnostics`.
   - Read the relevant code and surrounding context using `read`.

3. **Follow the 4 Steps**:
   - **Identify the Issues**: Read the code carefully. Pinpoint logic errors, unhandled edge cases, resource leaks, or missing imports. Factor in user guidance: ${@:-none}.
   - **Plan the Fix**: Outline the plan for fixing the code in concise steps or pseudocode.
   - **Implement the Fix**: Apply the changes directly to the file using `edit`. Ensure the code:
     - Includes all necessary imports and dependencies.
     - Handles errors robustly without silent failures.
     - Adheres to project style and idioms.
   - **Explain the Fix**: Briefly explain what changes were made and why.

4. **Verify**:
   - Run relevant tests, linters, or typecheckers via bash.
   - If attached to Neovim via MCP, re-check diagnostics with `get_diagnostics` and notify via `notify`.
