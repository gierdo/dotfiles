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

install_model https://huggingface.co/TheBloke/CodeLlama-13B-Instruct-GGUF/resolve/main/codellama-13b-instruct.Q4_K_M.gguf codellama-13b-instruct.Q4_K_M.gguf
