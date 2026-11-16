---
description: Write minimal tests for code at cursor in Neovim or specified target
argument-hint: "[target or function]"
---
Write the smallest test that proves this code works, applying the `software-engineering` skill.

1. **Skills & Mindset**:
   - Activate the `software-engineering` skill (`/home/dominik/.pi/agent/skills/sw-engineer/SKILL.md`).
   - Adhere to the core principle: write the smallest runnable check that fails if the logic breaks. Avoid unnecessary test fixtures or excess framework boilerplate.

2. **Identify Target Code**:
   - If a target file, function, or description is specified in `${@:-}`, inspect it.
   - Otherwise, if `nvim-editor-mcp` is available:
     - Query Neovim via `nvim_exec_lua` to find the active buffer and cursor location:
       `local buf = vim.api.nvim_get_current_buf(); return { path = vim.api.nvim_buf_get_name(buf), cursor = vim.api.nvim_win_get_cursor(0), filetype = vim.bo[buf].filetype }`
     - Read the enclosing function/method and module context using `read`.

3. **Determine Testing Conventions**:
   - Detect the existing test framework and directory structure (e.g. `cargo test`, `pytest`, `vitest`/`jest`, `go test`, etc.).
   - Follow project conventions for test naming and assertions. If the language has a standard built-in test runner, use it. Otherwise, write a standalone script with assertions that exits non-zero on failure.

4. **Test Design**:
   - Identify the contract and edge cases of the code under test.
   - Ensure coverage for:
     - Normal happy paths
     - Boundary values and subtle edge cases
     - Error handling, invalid inputs, and failure modes
   - Only test the targeted logic; do not add redundant tests for unmodified code.

5. **Implementation & Verification**:
   - Write or update test files using `edit` or `write`.
   - Run the test suite via bash to confirm the tests compile and pass.
   - If `nvim-editor-mcp` is connected, notify the result via `mcp__nvim_editor_mcp__notify`.
