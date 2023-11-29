#!/bin/bash

WORKDIR=~/Downloads/nvim/

mkdir -p $WORKDIR
cd $WORKDIR

wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
tar -zxvf nvim-linux64.tar.gz
cd nvim-linux64
cp -R ./* ~/.local/
cd
rm -rf $WORKDIR
