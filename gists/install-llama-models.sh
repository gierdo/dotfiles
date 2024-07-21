#!/bin/bash

MODEL_DIRECTORY=~/.local/lib/llama/models

function install_model() {
  local _url="$1"
  local _name="$2"

  mkdir -p ${MODEL_DIRECTORY}
  cd ${MODEL_DIRECTORY} || exit

  if [ -f "$_name" ]; then
    echo "The model $_name is already installed"
  else
    wget -O "$_name" "$_url"
  fi
}

install_model https://huggingface.co/bartowski/Llama-3-8B-Instruct-Coder-GGUF/resolve/main/Llama-3-8B-Instruct-Coder-Q4_K_M.gguf Llama-3-8B-Instruct-Coder-Q4_K_M.gguf
install_model https://huggingface.co/lmstudio-community/Llama-3-Groq-8B-Tool-Use-GGUF/resolve/main/Llama-3-Groq-8B-Tool-Use-Q4_K_M.gguf Llama-3-Groq-8B-Tool-Use-Q4_K_M.gguf
