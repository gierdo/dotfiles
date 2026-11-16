---
description: Generate a conventional commit message for staged changes
argument-hint: "[instructions]"
---
Inspect the staged changes and generate a conventional commit message following the `software-engineering` skill standards.

1. **Inspect Changes**:
   - Run `git diff --staged` using bash to inspect all staged modifications.
   - If nothing is staged, run `git status`, notify the user that no changes are staged, and summarize unstaged changes that could be staged.

2. **Format Conventional Commit Message**:
   - Format: `<type>(<scope>): <short description>`
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
   - Subject line: 50 characters or fewer, imperative mood ("add", not "added" or "adds"), lowercase, no trailing period.
   - Scope is optional; only include when obvious from context.
   - If a body is necessary to describe motivation or context, add a blank line and wrap at 72 characters. Focus on why and what rather than how.
   - If there are breaking changes, include `BREAKING CHANGE:` in the footer.
   - User instructions to consider: ${@:-none}.

3. **Output**:
   - Output ONLY the commit message in a single code block, with no additional commentary or preamble.
