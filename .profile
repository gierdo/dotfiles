# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export EDITOR=nvim

export PATH="$HOME/.local/share/nvim/lazy/fzf/bin:$PATH"
export PATH="$HOME/.dotfiles/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

export PATH="$HOME/.local/share/mise/shims:$PATH"

# set up go as needed. GOPRIVATE is set up together with .gitconfig
export PATH=$PATH:~/go/bin
export GOPATH=~/go
export GOPRIVATE=github.com

if [ -f "$HOME/.ghcup/env" ]; then
  . "$HOME/.ghcup/env"
fi

# Set up node environment
PATH="$HOME/.npmpath/bin:$PATH"
export NODE_PATH="$HOME/.npmpath/lib/node_modules"

if [ -d "/usr/lib/ccache" ]; then
  PATH="/usr/lib/ccache:$PATH"
fi

export ANDROID_HOME=~/.android-sdks
export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which javac))))"

if command -v rg 1>/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="$HOME/.dotfiles/.ripgreprc"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden .'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden .'
fi

# Theming, look and feel of newt apps, e.g. nmtui, whiptail scripts
export NEWT_COLORS='
    root=white,black
    border=black,lightgray
    window=lightgray,lightgray
    shadow=black,gray
    title=black,lightgray
    button=black,cyan
    actbutton=white,cyan
    compactbutton=black,lightgray
    checkbox=black,lightgray
    actcheckbox=lightgray,cyan
    entry=black,lightgray
    disentry=gray,lightgray
    label=black,lightgray
    listbox=black,lightgray
    actlistbox=black,cyan
    sellistbox=lightgray,black
    actsellistbox=lightgray,black
    textbox=black,lightgray
    acttextbox=black,cyan
    emptyscale=,gray
    fullscale=,cyan
    helpline=white,black
    roottext=lightgrey,black
'

# make (linux) menuconfig less bright
export MENUCONFIG_COLOR=blackbg

if command -v keychain 1>/dev/null 2>&1; then
  eval "$(keychain -q --eval id_rsa)"
fi

# fix curses pinentry
export GPG_TTY=$(tty)

# persuade cmake to always export compile commands
export CMAKE_EXPORT_COMPILE_COMMANDS=1

# Use the podman socket as replacement for docker, to be used by testcontainers etc.
if command -v podman 1>/dev/null 2>&1; then
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock

  if [ -f "$HOME/.docker/config.json" ]; then
    export REGISTRY_AUTH_FILE="$HOME/.docker/config.json"
  fi
fi

if command -v nix 1>/dev/null 2>&1; then
  NIX_PROFILE="$HOME/.nix-profile"
  if [ -d "$NIX_PROFILE" ]; then
    export XDG_CONFIG_DIRS="$NIX_PROFILE/etc/":$XDG_DATA_DIRS
    export XDG_DATA_DIRS="$NIX_PROFILE/share/":$XDG_DATA_DIRS
  fi

  NIX_EXTRA_PROFILES=$HOME/.nix-extra-profiles
  if [ -d "$NIX_EXTRA_PROFILES" ]; then
    for i in "$NIX_EXTRA_PROFILES"/*; do
      profile=$i/$(basename "$i")
      if [ -f "$profile"/etc/profile.d/nix.sh ]; then
        NIX_PROFILE="$profile"
        . "$NIX_PROFILE"/etc/profile.d/nix.sh

        if [ -d "$NIX_PROFILE/share" ]; then
          export XDG_CONFIG_DIRS="$NIX_PROFILE/etc/":$XDG_DATA_DIRS
          export XDG_DATA_DIRS="$NIX_PROFILE/share/":$XDG_DATA_DIRS
        fi
      fi
      unset profile
    done
  fi
fi

if [ -f "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# Autostart sway session on specific tty
if [ -z $WAYLAND_DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  # sway is installed, simply assuming sway as session for now
  if command -v sway 1>/dev/null 2>&1; then
    export QT_STYLE_OVERRIDE=kvantum
    export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"

    if command -v flatpak 1>/dev/null 2>&1; then
      export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS"
    fi

    # setting gdk_backend and qt_qpa_platform manually may cause trouble
    # export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
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

    export GTK_THEME=adw-gtk3-dark

    # gnome-keyring will be set up by sway and unlocked by pam
    if [ -f "/usr/libexec/gcr-ssh-agent" ]; then
      export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gcr/ssh"
    else
      export SSH_AUTH_SOCK="$GNOME_KEYRING_CONTROL/ssh"
    fi

    # Fix Java AWT applications on wayland
    export _JAVA_AWT_WM_NONREPARENTING=1

    # If you want to debug sway, `touch ~/sway.log`
    if [ -f "$HOME/sway.log" ]; then
      exec sway -d >>~/sway.log 2>&1
    else
      exec sway
    fi
  fi
fi
