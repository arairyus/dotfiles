if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# golang
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/shims:$PATH"
eval "$(goenv init -)"

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryusei/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryusei/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryusei/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryusei/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$PATH:~/code/work/anx/sqlpackage"
export PATH="$PATH:~/sqlpackage"
export PATH="$PATH:~/sqlpackage/sqlpackage"

# eval `/usr/libexec/path_helper -s`

