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
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
PATH=$PATH:/home/dominik/.skripte
export ANDROID_HOME=~/.android-sdks
export JAVA_HOME=$(dirname $(dirname $(readlink -f  /usr/bin/javac)))
#JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

export ECLIPSE_HOME=/opt/eclipse

export DEBFULLNAME="Dominikus Gierlach"
export DEBEMAIL="dominik.gierlach@gmail.com"

# New environment setting added by Freescale Kinetis SDK v1.1.0 on Mon Sep 14 11:52:43 CEST 2015 1.
# The unmodified version of this file is saved in /home/dominik/.profile1927068572.
# Do NOT modify these lines; they are used to uninstall.
KSDK_PATH=/home/dominik/Freescale/KSDK_1.1.0
export KSDK_PATH
# End comments by InstallAnywhere on Mon Sep 14 11:52:43 CEST 2015 1.
