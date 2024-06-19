# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export EDITOR=nvim

export PATH="$HOME/.dotfiles/.local/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/nvim/lazy/fzf/bin:$PATH"

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
# Fix for   reason: 'unsupported',code: 'ERR_OSSL_EVP_UNSUPPORTED'
export NODE_OPTIONS=--openssl-legacy-provider

if [ -d "/usr/lib/ccache" ]; then
  PATH="/usr/lib/ccache:$PATH"
fi

export ANDROID_HOME=~/.android-sdks
export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which javac))))"

if [ -d "$HOME/.dotfiles/pyenv/bin" ]; then
  export PYENV_ROOT="$HOME/.dotfiles/pyenv"
  export PYTHON_CONFIGURE_OPTS="--enable-shared"
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

# Use the podman socket as replacement for docker, to be used by testcontainers etc.
if command -v podman 1>/dev/null 2>&1; then
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock

  if [ -f "$HOME/.docker/config.json" ]; then
    export REGISTRY_AUTH_FILE="$HOME/.docker/config.json"
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

#
if [ "$(tty)" = "/dev/tty1" ]; then
  # sway is installed, simply assuming sway as session for now
  if command -v sway 1>/dev/null 2>&1; then
    export QT_QPA_PLATFORMTHEME=qt5ct
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

    # Assume gnome-keyring is set up
    export SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh"

    # Fix Java AWT applications on wayland
    export _JAVA_AWT_WM_NONREPARENTING=1

    # Android studio breaks on sway if the shipped jdk is used for the UI
    export STUDIO_JDK=/usr/lib/jvm/java-11-openjdk-amd64/

    # Autostart sway on tty1
    if lshw -C display 2>/dev/null | grep -qi "vendor.*nvidia"; then
      exec sway --unsupported-gpu
    else
      exec sway
    fi
  else
    # Autostart x session (i3) on tty1
    [ "$(tty)" = "/dev/tty1" ] && exec startx
  fi
fi
