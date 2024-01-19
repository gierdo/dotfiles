#!/usr/bin/env zsh

_fzf_compgen_path() {
    rg --files . "$1"
}

_fzf_compgen_dir() {
   fd --type d --hidden . "$1"
}
