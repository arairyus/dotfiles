if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Cloud
## google cloud
if [ -f '/Users/ryusei/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryusei/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/ryusei/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryusei/google-cloud-sdk/completion.zsh.inc'; fi
USE_GKE_GCLOUD_AUTH_PLUGIN=True
## aws
export PATH=/usr/local/bin/aws_completer:$PATH
### eksctl
fpath=($fpath ~/.zsh/completion)
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# golang
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# github
eval "$(gh completion -s zsh)"

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH #Issue?
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
fi

# prompt
source ~/.zsh/git-prompt.sh
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/completion/git-completion.bash
autoload -Uz compinit && compinit
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
PROMPT='%n@%m %c'\$vcs_info_msg_0_' %# '
precmd(){ vcs_info }
export PATH="$HOME/.tgenv/bin:$PATH"
