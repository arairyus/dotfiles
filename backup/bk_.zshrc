alias brew="env PATH=${PATH/\/Users\/${USER}\/.pyenv\/shims:/} brew"
alias python="python3" 
alias pip="pip3" 

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# direnv
eval "$(direnv hook zsh)"
export 'EDITOR=vim'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# nodeenv
eval "$(nodenv init -)"
export PATH="$PATH:$(npm bin -g)"

# zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH #Issue?
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
fi

# aws cli
export PATH=/usr/local/bin/aws_completer:$PATH

# eksctl
fpath=($fpath ~/.zsh/completion)
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# google-sdk
if [ -f '/Users/ryusei/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryusei/google-cloud-sdk/path.zsh.inc'; fi
# gcloud
if [ -f '/Users/ryusei/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryusei/google-cloud-sdk/completion.zsh.inc'; fi
USE_GKE_GCLOUD_AUTH_PLUGIN=True

# kubectl 
source <(kubectl completion zsh)
## istio
export PATH=/Users/ryusei/istio-1.15.2/bin:$PATH

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(rbenv init -)"

#github
eval "$(gh completion -s zsh)"


#alias
alias tg='terragrunt'
alias tf='terraform'
alias dk='docker'

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
