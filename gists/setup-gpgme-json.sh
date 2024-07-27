#!/bin/bash

REPO_NAME=gpgme
REPO_BASE=~/workspace
REPO_DIRECTORY=$REPO_BASE/$REPO_NAME

RELEASE_TAG=gpgme-1.23.2

if [ -d $REPO_DIRECTORY ]; then
  echo "repo already exists"
else
  mkdir -p $REPO_BASE
  cd $REPO_BASE || return
  git clone git://git.gnupg.org/gpgme.git $REPO_NAME
fi

cd $REPO_DIRECTORY || return

git checkout $RELEASE_TAG
./autogen.sh
mkdir -p build
cd build || return
../configure --prefix="$HOME/.local"
make install

mkdir -p ~/.mozilla/native-messaging-hosts
cat >~/.mozilla/native-messaging-hosts/gpgmejson.json <<EOF
{
  "name": "gpgmejson",
  "description": "JavaScript binding for GnuPG",
  "path": "$HOME/.local/bin/gpgme-json",
  "type": "stdio",
  "allowed_extensions": [
  "jid1-AQqSMBYb0a8ADg@jetpack"
  ]
}
EOF

mkdir -p ~/.config/google-chrome/NativeMessagingHosts
cat >~/.config/google-chrome/NativeMessagingHosts/gpgmejson.json <<EOF
{
  "name": "gpgmejson",
  "description": "JavaScript binding for GnuPG",
  "path": "$HOME/.local/bin/gpgme-json",
  "type": "stdio",
  "allowed_origins": [
  "chrome-extension://kajibbejlbohfaggdiogboambcijhkke/"
  ]
}
EOF
