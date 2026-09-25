---
name: Commit message
interaction: chat
description: Generate a conventional commit message for staged changes
opts:
  alias: commit
  auto_submit: true
  stop_context_insertion: true
---

## user

Generate a conventional commit message. Subject ≤50 chars, imperative mood.
If a body is needed, wrap at 72 chars. No scope unless obvious. No fluff.
Output ONLY the commit message, nothing else.

Here is the staged diff:

```diff
${commit.diff}
```
