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
PATH="$HOME/.cargo/bin:$PATH"
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

if [ -f "$HOME/.dotfiles/asdf/asdf.sh" ]; then
  . "$HOME/.dotfiles/asdf/asdf.sh"
fi

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
  . "$GUIX_PROFILE/etc/profile"
fi

GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
for i in $GUIX_EXTRA_PROFILES/*; do
  profile=$i/$(basename "$i")
  if [ -f "$profile"/etc/profile ]; then
    GUIX_PROFILE="$profile"
    . "$GUIX_PROFILE"/etc/profile
  fi
  unset profile
done

if command -v virtualenvwrapper.sh &>/dev/null; then
  export VIRTUALENVWRAPPER_PYTHON=$(which python3)
  export WORKON_HOME=$HOME/.virtualenvs/
  export PROJECT_HOME=$HOME/workspace
  export PIP_VIRTUALENV_BASE=$WORKON_HOME
  export PIPENV_IGNORE_VIRTUALENVS=1
  . $(which virtualenvwrapper.sh)
fi

export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

export EDITOR=vim

if [ -f "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi
