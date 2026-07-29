---
name: Test
interaction: chat
description: Write the minimal test for selected code
opts:
  alias: test
  is_slash_cmd: false
  modes:
    - v
  stop_context_insertion: true
---

## user

Write the smallest test that proves this code works.

If the project already has tests, adhere to the existing test framework and
convention.

If the language has a built-in test runner
(e.g. `cargo test`, `go test`, `python -m pytest` with bare asserts), use that
convention. Otherwise a standalone script with asserts that exits non-zero on
failure.

Follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the
   tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the
   identified programming language.
5. Ensure the tests cover:
    - Normal cases
    - Edge cases
    - Error handling (if applicable)

Write a minimal test for this ${context.filetype} code:

```${context.filetype}
#{selection}
```
