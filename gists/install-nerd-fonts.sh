#!/bin/bash

FONT_DIRECTORY="${HOME}/.local/share/fonts/NerdFonts"

declare -a FONT_FAMILIES=(
  "0xProto"
  "3270"
  "Agave"
  "AnonymousPro"
  "Arimo"
  "AurulentSansMono"
  "BigBlueTerminal"
  "BitstreamVeraSansMono"
  "CascadiaCode"
  "CascadiaMono"
  "CodeNewRoman"
  "ComicShannsMono"
  "CommitMono"
  "Cousine"
  "D2Coding"
  "DaddyTimeMono"
  "DejaVuSansMono"
  "DepartureMono"
  "DroidSansMono"
  "EnvyCodeR"
  "FantasqueSansMono"
  "FiraCode"
  "FiraMono"
  "GeistMono"
  "Go-Mono"
  "Gohu"
  "Hack"
  "Hasklig"
  "HeavyData"
  "Hermit"
  "iA-Writer"
  "IBMPlexMono"
  "Inconsolata"
  "InconsolataGo"
  "InconsolataLGC"
  "IntelOneMono"
  "Iosevka"
  "IosevkaTerm"
  "IosevkaTermSlab"
  "JetBrainsMono"
  "Lekton"
  "LiberationMono"
  "Lilex"
  "MartianMono"
  "Meslo"
  "Monaspace"
  "Monofur"
  "Monoid"
  "Mononoki"
  "MPlus"
  "Noto"
  "OpenDyslexic"
  "Overpass"
  "ProFont"
  "ProggyClean"
  "Recursive"
  "RobotoMono"
  "ShareTechMono"
  "SourceCodePro"
  "SpaceMono"
  "Terminus"
  "Tinos"
  "Ubuntu"
  "UbuntuMono"
  "UbuntuSans"
  "VictorMono"
  "ZedMono"
)

function install_font() {
  local _font_name="$1"

  local _font_archive="${_font_name}.tar.xz"
  echo "Installing $_font_name"

  curl -OL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${_font_archive}"
  tar xf "$_font_archive"

  rm "$_font_archive"
}

if [ -d "$FONT_DIRECTORY" ]; then
  echo "Fonts already installed"
  exit 0
else
  mkdir -p "$FONT_DIRECTORY" && cd "$FONT_DIRECTORY" || exit
  echo "Installing Nerdfonts"

  for font_family in "${FONT_FAMILIES[@]}"; do
    install_font "$font_family"
  done

  fc-cache -fv
fi
