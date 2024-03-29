#! /bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $BASE_DIR

for ENTRY in `ls -a $BASE_DIR`
do
  if [ -f $ENTRY ]; then
    if [[ $ENTRY =~ ^\..* ]]; then
      rm -rf ~/$ENTRY
      ln -sf $BASE_DIR/$ENTRY ~/$ENTRY | echo "linked $ENTRY"
    fi
  fi
done

if [ ! -d "~/.config" ]; then
  mkdir -p ~/.config
fi
for CONFIG in `ls $BASE_DIR/.config`
do
  if [ -d "$BASE_DIR/.config/$CONFIG" ]; then
    rm -rf ~/.config/$CONFIG
    ln -sf $BASE_DIR/.config/$CONFIG ~/.config/$CONFIG | echo "linked $CONFIG" | echo "linked .config/$CONFIG"
  fi
done


if [ -n "$BASH_VERSION" ]; then
  source ~/.bashrc
  echo "Run: source ~/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
  source ~/.zshrc
  echo "Run: source reloaded ~/.zshrc"
fi