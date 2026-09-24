#!/usr/bin/env bash
set -euo pipefail

# 1. Install Go tools
if command -v go >/dev/null 2>&1; then
  go_packages=(
    "github.com/bazelbuild/bazelisk@latest"
    "github.com/Gelio/go-global-update@latest"
    "github.com/google/yamlfmt/cmd/yamlfmt@latest"
    "github.com/jesseduffield/lazydocker@latest"
    "github.com/pranshuparmar/witr/cmd/witr@latest"
    "golang.org/x/lint/golint@latest"
    "golang.org/x/tools/cmd/goimports@latest"
    "golang.org/x/tools/gopls@latest"
    "mvdan.cc/sh/v3/cmd/shfmt@latest"
  )
  for pkg in "${go_packages[@]}"; do
    go install "$pkg" || true
  done
fi

# 2. Install NPM packages
if command -v npm >/dev/null 2>&1; then
  npm_packages=(
    "@1mcp/agent"
    "bash-language-server"
    "@bufbuild/buf"
    "bun"
    "concurrently"
    "copy"
    "cross-spawn"
    "dockerfile-language-server-nodejs"
    "esparse"
    "fixjson"
    "http-signature"
    "init-package-json"
    "js-yaml"
    "libcipm"
    "libnpmpublish"
    "lstat"
    "@mistweaverco/kulala-ls"
    "mkdirp"
    "neovim"
    "node-gyp"
    "normalize-package-data"
    "prettier"
    "rimraf"
    "shellcheck"
    "typescript"
    "typescript-language-server"
    "vscode-languageserver"
    "which"
    "yaml-language-server"
    "yarn"
  )
  npm install -g "${npm_packages[@]}" || true
fi

# 3. Install UV & Python CLI tools
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh || true
fi

if command -v uv >/dev/null 2>&1; then
  python_tools=(
    "autopep8"
    "black"
    "cfn-lint"
    "debugpy"
    "flake8"
    "podman-compose"
    "poetry"
    "pylint"
    "pytype"
    "pysentry-rs"
    "git+https://github.com/oraios/serena"
    "virtualenv"
    "visidata"
    "keyring"
  )
  for tool in "${python_tools[@]}"; do
    uv tool install --force "$tool" || true
  done
fi
