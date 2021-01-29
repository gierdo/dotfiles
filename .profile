# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

PATH="$HOME/.scripts:$PATH"
PATH="$HOME/.yarn/bin:$PATH"
PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
PATH="$HOME/.npmpath/bin:$PATH"
PATH="$HOME/.gem/ruby/current/bin:$PATH"
PATH="$HOME/.luarocks/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"

PATH=$PATH:~/go/bin
export GOPATH=~/go

export ANDROID_HOME=~/.android-sdks

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export JAVA_HOME="$(dirname $(dirname $(readlink -f /usr/bin/javac)))"
else
  export JAVA_HOME="$(/usr/libexec/java_home)"
fi

if [ -d "/usr/lib/ccache" ]; then
  PATH="/usr/lib/ccache:$PATH"
  if [ -d "/usr/lib/distcc" ]; then
    export CCACHE_PREFIX="distcc"
  fi
fi

if command -v guix 1>/dev/null 2>&1; then
  GUIX_PROFILE="$HOME/.guix-profile"
  SSL_CERT_DIR_="$GUIX_PROFILE/etc/ssl/certs"
  if [ -d "$SSL_CERT_DIR_" ]; then
    export SSL_CERT_DIR="$SSL_CERT_DIR_"
    export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
    export GIT_SSL_CAINFO="$SSL_CERT_FILE"
    export CURL_CA_BUNDLE="$SSL_CERT_FILE"
  fi

  export GUIX_LOCPATH=$GUIX_PROFILE/lib/locale
  . "$GUIX_PROFILE/etc/profile"

  GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
  for i in $GUIX_EXTRA_PROFILES/*; do
    profile=$i/$(basename "$i")
    if [ -f "$profile"/etc/profile ]; then
      GUIX_PROFILE="$profile"
      . "$GUIX_PROFILE"/etc/profile
    fi
    unset profile
  done
fi

if [ -f "$HOME/.dotfiles/asdf/asdf.sh" ]; then
  . "$HOME/.dotfiles/asdf/asdf.sh"
fi

if [ -d "$HOME/.dotfiles/pyenv/bin" ]; then
  export PYENV_ROOT="$HOME/.dotfiles/pyenv"
  PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  pyenv_virtualenv_plugin_root="$HOME/.dotfiles/pyenv-plugins/pyenv-virtualenv"
  if [ -d "$pyenv_virtualenv_plugin_root" ]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    PATH="$pyenv_virtualenv_plugin_root/bin:$PATH"
    eval "$(pyenv virtualenv-init -)"
  fi
fi

export EDITOR=vim

export QT_QPA_PLATFORMTHEME=qt5ct

# sway is installed, simply assuming sway as session for now
if command -v sway 1>/dev/null 2>&1; then
  export XDG_CURRENT_DESKTOP=sway
  export QT_QPA_PLATFORM=wayland-egl
  export GDK_BACKEND=wayland
  export CLUTTER_BACKEND=wayland
  export XDG_SESSION_TYPE=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_WEBRENDER=1
  # Fix idea on wayland
  export _JAVA_AWT_WM_NONREPARENTING=1
fi

if command -v rg 1>/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH=$HOME/.dotfiles/.ripgreprc
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# tbsm is installed, simply assuming tbsm as dm for now
if command -v tbsm 1>/dev/null 2>&1; then
  if [[ ! ${DISPLAY} && ${XDG_VTNR} == 1 ]]; then
    exec tbsm
  fi
fi

if command -v keychain 1>/dev/null 2>&1; then
  eval $(keychain -q --eval id_rsa)
fi

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ -f "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi
