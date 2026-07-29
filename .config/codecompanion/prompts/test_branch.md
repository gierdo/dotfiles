---
name: Test branch
interaction: chat
description: Generate tests for new code in the branch against a merge base
opts:
  alias: test_branch
  auto_submit: true
  stop_context_insertion: true
---

## user

Write the smallest tests that prove the new code in this branch works.

If the project already has tests, adhere to the existing test framework and
convention.

If the language has a built-in test runner
(e.g. `cargo test`, `go test`, `python -m pytest` with bare asserts), use that
convention. Otherwise a standalone script with asserts that exits non-zero on
failure.

Follow these steps:

1. Identify all new or changed functions/modules in the diff.
2. For each, list the edge cases and typical use cases that should be covered.
3. Generate minimal unit tests covering:
    - Normal cases
    - Edge cases
    - Error handling (if applicable)
4. Only test new/changed code — don't re-test unmodified code.

Here is the diff of the current branch against the merge base with `${test_branch.target_branch}`:

```diff
${test_branch.diff}
```
