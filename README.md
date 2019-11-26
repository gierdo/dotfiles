# Content

This repo contains a collection of dotfiles and other related files that pose
the core of my system setup.

# Purpose

The main purpose of this repo is portability and backup of my own
configuration.

The repository can be cloned locally, relevant configuration files can be replaced with symlinks to the dotfiles file.

If this setup should be helpful to anybody else, please feel
free to copy, suggest, do whatever you like with it.

# Fonts

The "fonts" directory contains fonts from https://github.com/ryanoasis/nerd-fonts

# Other stuff

The core setup of my system also consists the following tools/files/fonts etc., this list is most likely not complete:

* neovim
* plug
* zsh
* ctags

# Git credential store

```
sudo apt-get install libsecret-1-dev
cp -r /usr/share/doc/git/contrib/credential/libsecret ./
cd libsecret
make
sudo cp git-credential-libsecret /usr/local/bin
```
