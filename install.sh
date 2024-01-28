#!/usr/bin/env bash -e
for ENTRY in `ls -a ~/dotfiles`
do
  if [ -f $ENTRY ]; then
    if [[ $ENTRY =~ ^\..* ]]; then
      ln -sF ~/dotfiles/$ENTRY ~/$ENTRY | echo "linked $ENTRY"
    fi
  fi
done

if [ ! -d "~/.config" ]; then
  mkdir -p ~/.config
fi
for CONFIG in `ls ~/dotfiles/.config`
do
  if [ -d $CONFIG ]; then
    rm -rf ~/.config/$CONFIG
    ln -sF ~/dotfiles/.config/$CONFIG ~/.config/$CONFIG | echo "linked $CONFIG"
  fi
done


if [ -n "$BASH_VERSION" ]; then
  source ~/.bashrc
  echo "Run: source ~/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
  source ~/.zshrc
  echo "Run: source reloaded ~/.zshrc"
fi