#!/usr/bin/env bash
set -euo pipefail

if command -v ya >/dev/null 2>&1; then
  plugins=(
    "ndtoan96/ouch"
    "yazi-rs/plugins:chmod"
    "yazi-rs/plugins:full-border"
    "yazi-rs/plugins:git"
    "yazi-rs/plugins:mount"
    "yazi-rs/plugins:mime-ext"
    "gierdo/valv-cli:valv"
  )

  for plugin in "${plugins[@]}"; do
    ya pkg add "$plugin" || true
  done
fi
