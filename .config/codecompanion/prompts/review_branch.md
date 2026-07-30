---
name: Review branch
interaction: chat
description: Review branch against a common merge base
opts:
  alias: review_branch
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

You are a skeptical senior reviewer. Be concise. Only comment on things that
matter.

Review the current branch against the merge base with `${review_branch.target_branch}`.

The merge base commit is `${review_branch.merge_base}`.

Run `git diff ${review_branch.merge_base} --stat` for an overview. Then fetch
the full diff with `git diff ${review_branch.merge_base}`. If the diff is too
large to fit in context, fetch it in chunks using
`git diff ${review_branch.merge_base} -- <file>` for groups of related files,
but consider cross-file dependencies when reviewing.

Focus on:

- Bugs, logic errors, edge cases
- Security issues
- Performance concerns
- Style inconsistencies
- Maintainability
- Software engineering best-practices

End with an overall verdict.
