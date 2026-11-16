---
description: Fix LSP diagnostics in current buffer or specified file via Neovim MCP
argument-hint: "[file]"
---
Fix LSP diagnostics reported in Neovim or by the project's linter/typechecker, applying the `software-engineering` skill mindset.

1. **Skills & Standards**:
   - Apply the `software-engineering` skill (`/home/dominik/.pi/agent/skills/sw-engineer/SKILL.md`): minimal clean code, standard library over dependencies, and edge-case correctness.

2. **Retrieve Diagnostics via nvim-editor-mcp**:
   - If a file path is provided in `${1:-}`, check diagnostics for that file.
   - Otherwise, if `nvim-editor-mcp` is available, query the active Neovim instance:
     - Run `nvim_exec_lua` to get the current buffer path and cursor position:
       `local buf = vim.api.nvim_get_current_buf(); return { path = vim.api.nvim_buf_get_name(buf), cursor = vim.api.nvim_win_get_cursor(0), filetype = vim.bo[buf].filetype }`
     - Call `get_diagnostics` for the active buffer (or across open buffers if empty).
     - Prioritize diagnostics at or near the cursor position, then address any other errors and warnings in the file.
   - If Neovim is not running or no diagnostics are returned from MCP, run the project's typechecker/linter (e.g. `cargo check`, `tsc --noEmit`, `eslint`, `ruff check`, etc.) via bash.

3. **Analyze Root Causes**:
   - Read the source code around the diagnostic locations using `read`.
   - Analyze root causes for each issue (e.g., type mismatch, missing imports, syntax error, incorrect parameter count, unhandled error/nullability).

4. **Apply Fixes**:
   - Apply minimal, precise fixes directly to the files using `edit`:
     - Include any required imports or declarations.
     - Ensure error handling follows project conventions.
     - Keep changes scoped to fixing the diagnostics without adding unrequested abstractions.

5. **Verification**:
   - Re-check diagnostics with `get_diagnostics` (or re-run the project typecheck command) to verify all errors and warnings are resolved.
   - If attached to Neovim, use `notify` to report that diagnostics are resolved, or `set_quickfix` if any diagnostic remains requiring manual intervention.

6. Provide a concise summary of the resolved issues and changes made.
