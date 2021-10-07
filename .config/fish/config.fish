set -gx SHELL (command -v fish)

if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end

fundle plugin 'evanlucas/fish-kubectl-completions'
fundle plugin 'sentriz/fish-pipenv'
fundle plugin 'PatrickF1/fzf.fish'

fundle init

pyenv init - | source
source "$HOME/.dotfiles/asdf/completions/asdf.fish"
if type -q thefuck
  thefuck --alias | source
end

if type -q gh
  gh completion -s fish | source
end

if type -q kubectl
  alias kubectl-show-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n'
end

if type -q podman
  alias docker=podman
end

alias vim=nvim
alias browsh='docker run --rm -it browsh/browsh'

if test -f "$HOME/.config.fish.local"
  source "$HOME/.config.fish.local"
end
