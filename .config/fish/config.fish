set -gx SHELL fish

if type -q pyenv
  pyenv init - | source
end

if type -q thefuck
  thefuck --alias | source
end

if type -q gh
  gh completion -s fish | source
end

if test -f "$HOME/.dotfiles/asdf/completions/asdf.fish"
  source "$HOME/.dotfiles/asdf/completions/asdf.fish"
end

if type -q nvim
  alias vim=nvim
end

if type -q kubectl
  alias kubectl-show-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n'
end

if test -f "$HOME/.config.fish.local"
  source "$HOME/.config.fish.local"
end
