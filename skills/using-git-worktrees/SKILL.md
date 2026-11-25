---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via Worktrunk (wt) and Herdr workspace registration
---

# Using Git Worktrees

## Overview

Ensure work happens in an isolated workspace managed by **Worktrunk (`wt`)** (https://worktrunk.dev/), paired with Herdr workspace registration (`herdr worktree open` and `herdr workspace close`) when running inside Herdr (`HERDR_ENV=1`).

**Core principle:** Detect existing isolation first. Use Worktrunk (`wt`) for all worktree creation, switching, hook execution, merging, and removal. Never call raw `git worktree` commands or legacy native worktree wrappers directly.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## Step 0: Detect Existing Isolation

**Before creating anything, check if you are already in an isolated workspace and inspect active worktrees.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)

# Inspect all active worktrees managed in this repository via Worktrunk
wt list --format=json
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree - treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. Skip to Step 2 (Project Setup & Baseline Verification). Do NOT create another worktree.

Report with branch state:

- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD, externally managed). Branch creation needed at finish time."

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in the main repository checkout.

Has the user (or orchestrator plan) already indicated their worktree preference in your instructions? If not, ask for consent before creating a worktree:

> "Would you like me to set up an isolated worktree with Worktrunk (`wt`)? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 2.

## Step 1: Create or Switch Worktree with Worktrunk (`wt`)

Use Worktrunk (`wt`, or `$WORKTRUNK_BIN` if set) to create or switch to the worktree and register it with Herdr when `HERDR_ENV=1`.

### Branch Naming Note (Git Ref Hierarchy Constraint)

When creating a task branch from an existing base branch `<base>`, use `<base>-<task>` (hyphen separator) rather than `<base>/<task>` if `<base>` already exists as a local branch. Git stores branch refs as files under `.git/refs/heads/`, so it cannot create directory-nested ref `refs/heads/<base>/<task>` when the file `refs/heads/<base>` already exists (e.g., if `feat/my-feature` exists, name task branches `feat/my-feature-task-1` rather than `feat/my-feature/task-1`).

### Provisioning & Herdr Registration

Always pass `--no-cd` and `-y` in non-interactive agent commands so `wt` does not hang on interactive prompts or require a shell wrapper function.

```bash
WT_BIN="${WORKTRUNK_BIN:-wt}"

# Create a new branch + worktree (or omit --create to switch to an existing branch)
result=$("$WT_BIN" switch --create "$BRANCH_NAME" --base "${BASE_BRANCH:-@}" --no-cd --format=json -y)
wtpath=$(printf '%s\n' "$result" | jq -r '.path // empty')

# Fallback if path was omitted from switch output: resolve from wt list
if [ -z "$wtpath" ]; then
  wtpath=$("$WT_BIN" list --format=json | jq -r --arg b "$BRANCH_NAME" '.[] | select(.branch == $b and .kind == "worktree") | .path' | head -n1)
fi

# If running inside Herdr (HERDR_ENV=1), open the worktree as a Herdr workspace:
if [ "${HERDR_ENV:-}" = "1" ]; then
  repo_root=$(git rev-parse --path-format=absolute --git-common-dir | sed 's|/\.git$||')
  open_json=$(herdr worktree open --cwd "$repo_root" --path "$wtpath" --label "${LABEL:-$BRANCH_NAME}" --no-focus --json)
  workspace_id=$(printf '%s\n' "$open_json" | jq -r '.result.workspace.workspace_id // .result.workspace.id // .workspace.workspace_id // .workspace.id // empty')
fi
```

Once created, execute subsequent commands in `"$wtpath"` (or pass `cwd: wtpath` and `workspace: workspace_id` when spawning worker subagents).

## Step 2: Project Setup & Verify Clean Baseline

### Worktrunk Hooks & Fallback Dependency Setup

Worktrunk automatically runs configured `post-create` and `post-start` hooks during `wt switch` (for example, copying untracked env files or installing/linking dependencies).

Only run manual fallback setup in the worktree if Worktrunk hooks have not already provisioned the project dependencies:

```bash
# Node.js (only if node_modules was not already created/linked by wt hooks)
if [ -f package.json ] && [ ! -d node_modules ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ] && [ ! -d .venv ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ] && [ ! -d .venv ]; then uv sync; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### Verify Clean Baseline

Run the project's test suite in the worktree to ensure the workspace starts clean:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

```
Worktree ready at <full-path> (branch: <branch-name>)
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Step 3: Merging & Removing Worktrees with Worktrunk

When work in the isolated worktree is complete and verified, merge and remove the worktree using Worktrunk, then close its Herdr workspace if one was opened.

- Pass `--no-remove` to `wt merge` because `wt merge`'s default removal runs in the background and can race with `herdr workspace close`.
- Run `wt remove --foreground` synchronously from the main worktree (`-C "$MAIN_WORKTREE_PATH"`) so the worktree directory and branch are completely removed before closing the Herdr workspace.

```bash
WT_BIN="${WORKTRUNK_BIN:-wt}"

# 1. Merge worktree branch into target branch (without racing background removal):
"$WT_BIN" merge "$TARGET_BRANCH" -C "$WTPATH" --no-remove -y

# 2. Remove worktree synchronously from main worktree:
"$WT_BIN" remove --foreground -C "$MAIN_WORKTREE_PATH" "$BRANCH_NAME" -y

# 3. If running inside Herdr (HERDR_ENV=1) and a workspace was opened, close it:
if [ "${HERDR_ENV:-}" = "1" ] && [ -n "${WORKSPACE_ID:-}" ]; then
  herdr workspace close "$WORKSPACE_ID"
fi
```

If discarding an unmerged worktree intentionally, add `--force -D` to `wt remove --foreground -C "$MAIN_WORKTREE_PATH" "$BRANCH_NAME" --force -D -y` before closing the Herdr workspace.

## Quick Reference

| Situation | Action |
| ----------- | -------- |
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Inspect active worktrees | `wt list --format=json` |
| Task branch from existing `<base>` branch | Name branch `<base>-<task>` (hyphen, not `<base>/<task>`) |
| Create worktree | `wt switch --create "$BRANCH" --base "$BASE" --no-cd --format=json -y` |
| Register worktree in Herdr (`HERDR_ENV=1`) | `herdr worktree open --cwd "$repo_root" --path "$wtpath" --label "$LABEL" --no-focus --json` |
| Dependencies already provisioned by `wt` hooks | Skip manual install, run baseline tests (Step 2) |
| Tests fail during baseline | Report failures + ask |
| Merge & clean up worktree | `wt merge "$TARGET" -C "$WTPATH" --no-remove -y` then `wt remove --foreground -C "$MAIN_PATH" "$BRANCH" -y` |
| Close Herdr workspace (`HERDR_ENV=1`) | `herdr workspace close "$WORKSPACE_ID"` |

## Common Rationalizations

| Excuse | Reality |
| -------- | --------- |
| "I'm obviously not in a worktree - no need to check" | Run Step 0. Linked worktrees and submodules both fool eyeballing; `git rev-parse` and `wt list --format=json` settle it. |
| "I'll just run `wt switch` without `--no-cd` or `-y`" | Without `--no-cd` and `-y`, non-interactive agent calls can fail for lack of shell integration or hang waiting for hook/confirmation prompts. |
| "I'll let `wt merge` remove the worktree automatically" | `wt merge` removes worktrees in the background by default, which races with `herdr workspace close`. Always use `wt merge ... --no-remove -y` followed by `wt remove --foreground ... -y`. |
| "I'll branch `<base>/<task>` off an existing `<base>` branch" | Git cannot create `refs/heads/<base>/<task>` when `refs/heads/<base>` exists as a file. Use `<base>-<task>` instead. |
| "The workspace is fresh - baseline tests can wait" | A dirty baseline makes every later failure ambiguous. Run the tests now; proceeding past failures is your human partner's call. |
