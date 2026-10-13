_fzf_compgen_path() {
  rg --files . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden . "$1"
}

if [ -d "$HOME/.local/share/nvim/lazy/fzf/bin" ]; then
  export PATH="$HOME/.local/share/nvim/lazy/fzf/bin:$PATH"
fi

if [ -f "$HOME/.fzf.zsh" ]; then
  source ~/.fzf.zsh
fi
