---
description: Resolve in-progress git merge or rebase conflicts
argument-hint: "[optional instructions]"
---
Resolve an in-progress git merge or rebase conflict, applying the `software-engineering` skill.

1. **Skills & Isolation**:
   - Activate the `software-engineering` skill (`/home/dominik/.pi/agent/skills/sw-engineer/SKILL.md`).
   - If feature isolation from the current workspace is needed before starting, consult the `using-git-worktrees` skill (`/home/dominik/.pi/agent/skills/using-git-worktrees/SKILL.md`).

2. **See the Current State**:
   - Run `git status` to find all unmerged/conflicting files.
   - Inspect git commit history and recent commits on both branches (`HEAD` and `MERGE_HEAD` / upstream) to understand the goals of each branch.
   - If `nvim-editor-mcp` is available, populate Neovim's quickfix list using `mcp__nvim_editor_mcp__set_quickfix` with the list of conflicting files and lines for easy navigation in Neovim.

3. **Find the Primary Sources for Each Conflict**:
   - Deeply understand why each change was made and what the original intent was on both sides.
   - Inspect commit logs (`git log -1 -p <commit>`) or blame for the conflicting lines.

4. **Resolve Each Hunk**:
   - Read each conflicting file using `read`.
   - Use `edit` to resolve all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
   - Preserve both intents where possible. Where incompatible, pick the one matching the merge/rebase's stated goal and note the trade-off.
   - Do NOT invent new behavior outside what is required to reconcile both sides.
   - Always resolve; never abort (`--abort`).
   - User instructions: ${@:-none}.

5. **Run Automated Checks**:
   - Discover the project's automated checks (e.g. typecheck, linter, test suite, format).
   - Run them via bash and fix anything the merge broke.

6. **Finish the Merge/Rebase**:
   - Stage resolved files with `git add <file>`.
   - If in a merge: run `git commit` with an appropriate merge commit message.
   - If in a rebase: run `git rebase --continue` and repeat until all commits are successfully rebased.
   - If `nvim-editor-mcp` is attached, notify via `mcp__nvim_editor_mcp__notify` that merge conflicts have been resolved.
