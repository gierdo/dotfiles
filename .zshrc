# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.dotfiles/oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="powerlevel9k"
source  ~/.dotfiles/themes/powerlevel10k/powerlevel10k.zsh-theme

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  git-extras
  aws
  cp
  adb
  docker
  golang
  gh
  ng
  sudo
  helm
  kubectl
  fancy-ctrl-z
  rust
  pipenv
  mvn
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Manually installed plugins

source ~/.dotfiles/zsh-plugins/fzf-tab/fzf-tab.plugin.zsh

source ~/.dotfiles/zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fpath=(~/.dotfiles/zsh-plugins/zsh-completions/src $fpath)

fpath=(~/.dotfiles/workspace/guix/etc/completion/zsh $fpath)

export PATH="$HOME/.dotfiles/zsh-plugins/git-fuzzy/bin:$PATH"

autoload -U compinit && compinit

# Powerlevel10k customization

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ZSH's glob matching messes with setting list-options in helm
# e.g. --set ingress.hosts[0]=flerb.bar
setopt +o nomatch

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi


if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if [ -f "$HOME/.dotfiles/asdf/completions/asdf.bash" ]; then
  source "$HOME/.dotfiles/asdf/completions/asdf.bash"
fi

alias kubectl-show-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n'

# Funny fun:
alias fucking='sudo '

if command -v thefuck 1>/dev/null 2>&1; then
  eval $(thefuck --alias)
fi

if command -v direnv 1>/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v podman 1>/dev/null 2>&1; then
  alias docker='podman'
fi

if command -v nvim 1>/dev/null 2>&1; then
  alias vim='nvim'
fi

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

if [ -f "$HOME/.fzf.zsh" ]; then
  source ~/.fzf.zsh
fi

