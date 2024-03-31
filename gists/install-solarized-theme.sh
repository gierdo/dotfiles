#!/bin/bash

THEME_DIRECTORY=~/.local/share/themes/Solarized-Dark-Cyan-GTK

if [ -d "$THEME_DIRECTORY" ]; then
  echo "solarized theme already installed"
  exit 0
else
  echo "Installing solarized theme"

  mkdir -p ~/.local/share/icons
  mkdir -p ~/.local/share/themes && cd ~/.local/share/themes || exit
  ln -sf ~/.local/share/themes ~/.themes

  wget https://github.com/rtlewis88/rtl88-Themes/archive/refs/tags/1.0.tar.gz
  tar -xvzf 1.0.tar.gz
  rm 1.0.tar.gz
  mv rtl88-Themes-1.0/solarized-dark-gtk-theme-colorpack_1.3.tar.gz ./
  mv rtl88-Themes-1.0/Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz ~/.local/share/icons/
  rm -r rtl88-Themes-1.0
  tar -xvzf solarized-dark-gtk-theme-colorpack_1.3.tar.gz
  rm solarized-dark-gtk-theme-colorpack_1.3.tar.gz
  cd ~/.local/share/icons || exit
  tar -xvzf Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz
  rm Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Solarized-Dark-Cyan-GTK'
gsettings set org.gnome.desktop.interface icon-theme 'Solarized-Cyan-gtk-theme-iconpack'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'
