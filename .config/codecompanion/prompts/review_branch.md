---
name: Review branch
interaction: chat
description: Review branch against a common merge base
opts:
  alias: review_branch
  auto_submit: true
  stop_context_insertion: true
---

## user

Review the following diff of the current branch against the merge base with `${review_branch.target_branch}`

Focus on
-

- Bugs, logic errors, edge cases
- Security issues
- Performance concerns
- Style inconsistencies
- Maintainability
- Software engineering best-practices

Be concise. Only comment on things that matter.

Here comes the diff to review:

```diff
${review_branch.diff}
```
