#!/usr/bin/env bash
set -euo pipefail

if command -v sccache >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/lib/sccache"
  for cmd in cc c++ gcc g++ clang clang++; do
    ln -sf "$(command -v sccache)" "$HOME/.local/lib/sccache/$cmd"
  done
fi
