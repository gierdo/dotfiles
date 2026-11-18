---
description: Resolve in-progress git conflicts (merge, rebase, cherry-pick, revert, am, stash)
argument-hint: "[optional instructions]"
---
Resolve an in-progress git conflict, applying the `software-engineering` skill. This covers every conflict-producing operation: `merge`, `rebase` (including interactive and `git am`), `cherry-pick`, `revert`, and `stash pop`/`apply`.

1. **Skills & Isolation**:
   - Activate the `software-engineering` skill (`skills/sw-engineer/SKILL.md`).
   - If feature isolation from the current workspace is needed first, consult the `using-git-worktrees` skill (`skills/using-git-worktrees/SKILL.md`).

2. **Detect Which Operation Is In Progress**:
   - Run `git status` first; it usually names the operation and the correct continue/abort commands.
   - Confirm by probing the repository's git dir (resolve it with `git rev-parse --git-dir`), since `git status` wording can be ambiguous. Exactly one of these determines the finishing command:
     - `MERGE_HEAD` present → **merge** (also covers `git pull` merges).
     - `rebase-merge/` or `rebase-apply/` directory present → **rebase**. If `rebase-apply/applying` exists (and there is no `rebase-merge/`), it is a **`git am`** session.
     - `CHERRY_PICK_HEAD` present → **cherry-pick**.
     - `REVERT_HEAD` present → **revert**.
     - None of the above but `git status` shows "Unmerged paths" → a **stash pop/apply** conflict (or a conflict left by `git checkout -m`/`git stash branch`). There is no operation sentinel and no abort step; the stash entry is NOT dropped automatically on a conflicted `pop`.
   - Note the operation type now; step 6 branches on it.

3. **See the Current State**:
   - Run `git status` to find all unmerged/conflicting files.
   - Inspect git commit history and recent commits on both sides to understand each side's goal. The "ours"/"theirs" meaning depends on the operation (see note below).
   - If `nvim-editor-mcp` is available, populate Neovim's quickfix list using `mcp__nvim_editor_mcp__set_quickfix` with the list of conflicting files and lines for easy navigation in Neovim.

4. **Find the Primary Sources for Each Conflict**:
   - Deeply understand why each change was made and what the original intent was on both sides.
   - Identify the relevant commits for the operation, then inspect them (`git log -1 -p <commit>`) or blame the conflicting lines:
     - merge: `HEAD` (ours) vs `MERGE_HEAD` (theirs).
     - rebase: the commit being replayed is "theirs"; the new base is "ours". During a rebase, "ours" and "theirs" are swapped relative to intuition — ours = the branch you are rebasing onto, theirs = the commit being applied.
     - cherry-pick / revert: `HEAD` (ours) vs `CHERRY_PICK_HEAD` / `REVERT_HEAD` (theirs).
     - `git am`: the patch being applied is "theirs"; inspect it via `git am --show-current-patch`.
     - stash pop/apply: `HEAD`/working tree (ours) vs the stashed changes (theirs); inspect with `git stash show -p`.
   - For the three-way context of any file, `git show :1:<file>` (base), `:2:<file>` (ours), `:3:<file>` (theirs) are available.

5. **Resolve Each Hunk**:
   - Read each conflicting file using `read`.
   - Use `edit` to resolve all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`, and `|||||||` when `diff3`/`zdiff3` style is configured — keep none of the marker lines).
   - Handle non-content conflicts too: for add/add, modify/delete, rename, and deleted-file conflicts, decide the final state and use `git add <file>` or `git rm <file>` accordingly.
   - Preserve both intents where possible. Where incompatible, pick the one matching the operation's stated goal and note the trade-off.
   - Do NOT invent new behavior outside what is required to reconcile both sides.
   - Always resolve; never abort (`--abort` / `git stash` re-stash) unless the user explicitly asks.
   - User instructions: ${@:-none}.

6. **Run Automated Checks**:
   - Discover the project's automated checks (e.g. typecheck, linter, test suite, format).
   - Run them via bash and fix anything the conflict resolution broke.

7. **Finish the Operation** (branch on the type detected in step 2):
   - Stage resolved files with `git add <file>` (and `git rm <file>` for intentional deletions). Confirm `git status` shows no remaining unmerged paths before continuing.
   - **merge**: `git commit` (completes the pending merge commit using `MERGE_MSG`).
   - **rebase**: `git rebase --continue`. Repeat steps 3-6 for each subsequent commit that conflicts until the rebase completes.
   - **`git am`**: `git am --continue`. Repeat for each remaining patch that conflicts.
   - **cherry-pick**: `git cherry-pick --continue`. Repeat for each remaining commit in a multi-commit cherry-pick.
   - **revert**: `git revert --continue`. Repeat for each remaining commit in a multi-commit revert.
   - **stash pop/apply**: there is nothing to `--continue`. After staging, the working tree holds the resolved result. A conflicted `git stash pop` does NOT drop the stash — verify the merge is correct, then drop it explicitly with `git stash drop` only if the user wants the stash removed (do not drop if resolution is uncertain). Do not create a commit unless asked.
   - If `nvim-editor-mcp` is attached, notify via `mcp__nvim_editor_mcp__notify` that the conflicts have been resolved.

8. **Report**:
   - State which operation was resolved, how many files/commits were involved, any trade-offs made, and the result of the automated checks.
