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

install_model https://huggingface.co/bartowski/dolphin-2.8-mistral-7b-v02-GGUF/resolve/main/dolphin-2.8-mistral-7b-v02-Q4_K_M.gguf dolphin-2.8-mistral-7b-v02-Q4_K_M.gguf
install_model https://huggingface.co/QuantFactory/Meta-Llama-3-8B-Instruct-GGUF/resolve/main/Meta-Llama-3-8B-Instruct.Q4_K_M.gguf Meta-Llama-3-8B-Instruct.Q4_K_M.gguf
