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

install_model https://huggingface.co/TheBloke/dolphin-2.6-mistral-7B-dpo-laser-GGUF/resolve/main/dolphin-2.6-mistral-7b-dpo-laser.Q4_K_M.gguf dolphin-2.6-mistral-7b-dpo-laser.Q4_K_M.gguf
install_model https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf mistral-7b-instruct-v0.2.Q4_K_M.gguf
