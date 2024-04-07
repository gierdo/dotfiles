#!/bin/bash

THEME_DIRECTORY=~/.themes/Material-Solarized

if [ -d "$THEME_DIRECTORY" ]; then
  echo "solarized theme already installed"
  exit 0
else
  echo "Installing solarized theme"

  mkdir -p ~/.icons
  mkdir -p ~/.themes && cd ~/.themes || exit

  git clone --depth 1 --branch Material-Solarized-Complete-Desktop https://github.com/rtlewis1/GTK.git tmp

  mv tmp/Material-Solarized ./
  rm -rf tmp

  wget https://github.com/rtlewis88/rtl88-Themes/archive/refs/tags/1.0.tar.gz
  tar -xvzf 1.0.tar.gz
  rm 1.0.tar.gz
  mv rtl88-Themes-1.0/Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz ~/.icons/
  rm -r rtl88-Themes-1.0
  rm solarized-dark-gtk-theme-colorpack_1.3.tar.gz
  cd ~/.icons || exit
  tar -xvzf Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz
  rm Solarized-Colors-gtk-theme-iconpack_1.0.tar.gz
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Material-Solarized'
gsettings set org.gnome.desktop.interface icon-theme 'Solarized-Cyan-gtk-theme-iconpack'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'

if command -v flatpak 1>/dev/null 2>&1; then
  flatpak override --user --filesystem=$HOME/.icons
  flatpak override --user --filesystem=$HOME/.themes
  flatpak override --user --env=GTK_THEME=Material-Solarized
fi
