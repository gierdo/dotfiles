set -gx SHELL fish

# These dependencies are defined in the guix profile and dotfiles, we can assume they are present
pyenv init - | source
source "$HOME/.dotfiles/asdf/completions/asdf.fish"
source "$HOME/.guix-profile/src/github.com/junegunn/fzf/shell/key-bindings.fish"
if type -q thefuck
  thefuck --alias | source
end

if type -q gh
  gh completion -s fish | source
end

if type -q kubectl
  alias kubectl-show-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n'
end

alias docker=podman
alias vim=nvim
alias browsh='docker run --rm -it browsh/browsh'

if test -f "$HOME/.config.fish.local"
  source "$HOME/.config.fish.local"
end
