#!/usr/bin/env bash
set -euo pipefail

# Install / update Cargo crates
if command -v cargo >/dev/null 2>&1; then
  crates=(
    "atuin"
    "bandwhich"
    "cargo-updater"
    "eza"
    "fd-find"
    "git-delta"
    "jj-cli"
    "lazyjj"
    "mergiraf"
    "mise"
    "netscanner"
    "ntap"
    "ouch"
    "pay-respects"
    "pay-respects-module-runtime-rules"
    "ripgrep"
    "tree-sitter-cli"
    "yazi-build"
    "zoxide"
    "engram_mcp"
  )

  for crate in "${crates[@]}"; do
    cargo install "$crate" || true
  done

  # Git cargo dependencies
  git_crates=(
    "https://github.com/gierdo/valv-cli.git"
    "https://github.com/Ataraxy-Labs/weave.git weave-cli"
    "https://github.com/Ataraxy-Labs/weave.git weave-driver"
  )

  for dep in "${git_crates[@]}"; do
    cargo install --git $dep || true
  done
fi
