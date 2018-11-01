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

if [ -f "$HOME/.profile.local" ]; then
  . "$HOME/.profile.local"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi
PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
PATH=$PATH:~/.scripts
PATH=$PATH:~/.local/bin
PATH=$PATH:~/.npmpath/bin

# go stuff
PATH=$PATH:~/go/bin
export GOPATH=~/go

export ANDROID_HOME=~/.android-sdks
export JAVA_HOME=$(dirname $(dirname $(readlink -f  /usr/bin/javac)))

