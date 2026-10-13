# Generic zsh Aliases
alias fucking='sudo '

alias :q='exit'
alias :wq='exit'

alias kubectl-show-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n'
alias ctop_podman='podman run --rm -ti \
  --name=ctop \
  --volume $XDG_RUNTIME_DIR/podman/podman.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest'

alias ctop='docker run --rm -ti \
  --name=ctop \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest'

alias dive='podman run -ti --rm  -v $XDG_RUNTIME_DIR/podman/podman.sock:/var/run/docker.sock wagoodman/dive'

alias bazel='bazelisk'
