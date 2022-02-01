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

PATH="$HOME/.dotfiles/.local/bin:$PATH"
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
  if [ -d "$GUIX_PROFILE" ]; then
    SSL_CERT_DIR_="$GUIX_PROFILE/etc/ssl/certs"
    if [ -d "$SSL_CERT_DIR_" ]; then
      export SSL_CERT_DIR="$SSL_CERT_DIR_"
      export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
      export GIT_SSL_CAINFO="$SSL_CERT_FILE"
      export CURL_CA_BUNDLE="$SSL_CERT_FILE"
    fi

    export GUIX_LOCPATH=$GUIX_PROFILE/lib/locale
    if [ -f "$GUIX_PROFILE"/etc/profile ]; then
      . "$GUIX_PROFILE/etc/profile"
    fi
  fi

  GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
  if [ -d "$GUIX_EXTRA_PROFILES" ]; then
    for i in $GUIX_EXTRA_PROFILES/*; do
      profile=$i/$(basename "$i")
      if [ -f "$profile"/etc/profile ]; then
        GUIX_PROFILE="$profile"
        . "$GUIX_PROFILE"/etc/profile

        if [ -d "$GUIX_PROFILE/share" ]; then
          export XDG_DATA_DIRS="$GUIX_PROFILE/share/":$XDG_DATA_DIRS
        fi
      fi
      unset profile
    done
  fi
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
    eval "$(pyenv init --path)"
  fi
fi

export EDITOR=nvim

export QT_QPA_PLATFORMTHEME=qt5ct

if command -v rg 1>/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH=$HOME/.dotfiles/.ripgreprc
  export FZF_DEFAULT_COMMAND='fd --type f --hidden .'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden .'
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

# sway is installed, simply assuming sway as session for now
if command -v sway 1>/dev/null 2>&1; then
  # setting gdk_backend and qt_qpa_platform manually causes trouble
  # export GDK_BACKEND=wayland
  # export QT_QPA_PLATFORM=wayland
  export XDG_CURRENT_DESKTOP=sway
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export CLUTTER_BACKEND=wayland
  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=sway
  export XDG_CURRENT_DESKTOP=sway
  export DESKTOP_SESSION=sway

  export LIBSEAT_BACKEND=logind

  export SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_WEBRENDER=1

  # Fix Java AWT applications on wayland
  export _JAVA_AWT_WM_NONREPARENTING=1

  # Android studio breaks on sway if the shipped jdk is used for the UI
  export STUDIO_JDK=/usr/lib/jvm/java-11-openjdk-amd64/

  # Autostart sway on tty1
  [ "$(tty)" = "/dev/tty1" ] && exec sway
fi
