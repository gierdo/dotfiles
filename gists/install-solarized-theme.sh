#!/bin/bash

THEME_DIRECTORY=~/.themes/adw-gtk3-dark

if [ -d "$THEME_DIRECTORY" ]; then
  echo "solarized theme already installed"
  exit 0
else
  echo "Installing solarized theme"

  mkdir -p ~/.icons
  mkdir -p ~/.themes && cd ~/.themes || exit

  wget -O "adw-gtk3.tar.xz" https://github.com/lassekongo83/adw-gtk3/releases/download/v5.3/adw-gtk3v5.3.tar.xz
  unp adw-gtk3.tar.xz
  rm adw-gtk3.tar.xz

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

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Solarized-Cyan-gtk-theme-iconpack'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'

if command -v flatpak 1>/dev/null 2>&1; then
  flatpak override --user --filesystem=$HOME/.icons/:ro
  flatpak override --user --filesystem=$HOME/.themes/:ro
  flatpak override --user --filesystem=$HOME/.dotfiles/.config/gtk-4.0/:ro
  flatpak override --user --env=GTK_THEME=adw-gtk3-dark
  flatpak override --user --filesystem=xdg-config/gtk-3.0
  flatpak override --user --filesystem=xdg-config/gtk-4.0
fi

if command -v kvantummanager 1>/dev/null 2>&1; then
  kvantummanager --set Solarized-Dark
fi
