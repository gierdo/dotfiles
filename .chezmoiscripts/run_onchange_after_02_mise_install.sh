#!/usr/bin/env bash
set -euo pipefail

if command -v mise >/dev/null 2>&1; then
  mise install -y
fi
