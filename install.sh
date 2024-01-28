#! /bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

for ENTRY in `ls -a $BASE_DIR`
do
  if [ -f $ENTRY ]; then
    if [[ $ENTRY =~ ^\..* ]]; then
    ln -sF $BASE_DIR/$ENTRY ~/$ENTRY | echo "linked $ENTRY"
    fi
  fi
done

if [ ! -d "~/.config" ]; then
  mkdir -p ~/.config
fi
for CONFIG in `ls $BASE_DIR/.config`
do
  if [ -d $CONFIG ]; then
    rm -rf ~/.config/$CONFIG
  ln -sF $BASE_DIR/.config/$CONFIG ~/.config/$CONFIG | echo "linked $CONFIG"
  fi
done


if [ -n "$BASH_VERSION" ]; then
  source ~/.bashrc
  echo "Run: source ~/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
  source ~/.zshrc
  echo "Run: source reloaded ~/.zshrc"
fi