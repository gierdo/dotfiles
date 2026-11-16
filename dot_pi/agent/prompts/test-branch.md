---
description: Generate minimal tests for new/changed code in branch against merge base
argument-hint: "[target_branch]"
---
Write the smallest tests that prove the new code in this branch works, applying the `software-engineering` skill.

1. **Skills & Mindset**:
   - Activate the `software-engineering` skill (`/home/dominik/.pi/agent/skills/sw-engineer/SKILL.md`).
   - Leave behind the smallest runnable check that fails if the new logic breaks. Only test new or changed code.

2. **Determine Branch Changes**:
   - Target branch: `${1:-main}`.
   - Find the merge base commit: `git merge-base HEAD ${1:-main}`.
   - Run `git diff $(git merge-base HEAD ${1:-main})..HEAD --stat` to list modified files.
   - Inspect the diff with `git diff $(git merge-base HEAD ${1:-main})..HEAD`.

3. **Analyze New & Modified Functionality**:
   - Identify all new or changed functions, methods, modules, and API endpoints.
   - Do NOT re-test unmodified code; focus strictly on what changed or was added.
   - For each component, identify:
     - Standard expected behavior
     - Critical edge cases and boundary conditions
     - Error handling, invalid states, and failure modes

4. **Follow Project Conventions**:
   - Adhere to the existing test framework and directory structure in the repository.
   - If no framework exists, follow built-in language conventions or create a standalone runner exiting non-zero on failure.

5. **Implement & Verify**:
   - Write the tests in appropriate test files using `edit` or `write`.
   - Run the test suite via bash to verify all newly added tests execute and pass.
   - If `nvim-editor-mcp` is connected, notify via `mcp__nvim_editor_mcp__notify` with the test outcome.
