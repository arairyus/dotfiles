#!/usr/bin/env bash -e
if [[ "$CODESPACES" ==  true ]]; then
  BASE_DIR="/workspaces/.codespaces/.persistedshare"
else
  BASE_DIR="$HOME"
fi

for ENTRY in `ls -a $BASE_DIR/dotfiles`
do
  if [ -f $ENTRY ]; then
    if [[ $ENTRY =~ ^\..* ]]; then
    ln -sF $BASE_DIR/dotfiles/$ENTRY ~/$ENTRY | echo "linked $ENTRY"
    fi
  fi
done

if [ ! -d "~/.config" ]; then
  mkdir -p ~/.config
fi
for CONFIG in `ls $BASE_DIR/dotfiles/.config`
do
  if [ -d $CONFIG ]; then
    rm -rf ~/.config/$CONFIG
  ln -sF $BASE_DIR/dotfiles/.config/$CONFIG ~/.config/$CONFIG | echo "linked $CONFIG"
  fi
done


if [ -n "$BASH_VERSION" ]; then
  source ~/.bashrc
  echo "Run: source ~/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
  source ~/.zshrc
  echo "Run: source reloaded ~/.zshrc"
fi