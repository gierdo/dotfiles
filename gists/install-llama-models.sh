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

install_model https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf
install_model https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf qwen2.5-coder-7b-instruct-q4_k_m.gguf
