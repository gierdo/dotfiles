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

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi
PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"

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

if [ -f "$HOME/.profile.local" ]; then
  source "$HOME/.profile.local"
fi
