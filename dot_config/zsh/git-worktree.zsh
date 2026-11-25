wta() { git worktree add -b "$1" "worktrees/$1" && cd "worktrees/$1"; }
wtc() { git worktree add "worktrees/$1" "$1" && cd "worktrees/$1"; }
compdef _wtc_branches wtc
_wtc_branches() {
  local branches
  branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes 2>/dev/null)"})
  compadd -a branches
}

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
