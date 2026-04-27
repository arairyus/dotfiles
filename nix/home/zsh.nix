{ ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    profileExtra = ''
      # ssh-agent
      if [ -z "$SSH_AUTH_SOCK" ]; then
        RUNNING_AGENT="$(ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')"
        if [ "$RUNNING_AGENT" = "0" ]; then
          ssh-agent -s &> $HOME/.ssh/ssh-agent
        fi
        eval "$(cat $HOME/.ssh/ssh-agent)"
      fi
    '';

    shellAliases = {
      python = "python3";
      pip = "pip3";
      tg = "terragrunt";
      tf = "terraform";
      tfdoc = "terraform-docs";
      tfscan = "terrascan";
      docker = "podman";
      docker-compose = "podman compose";
      dk = "podman";
      ll = "ls -l";
      la = "ls -al";
      k = "kubectl";
      kx = "kubectx";
      copilot = builtins.concatStringsSep " " [
        "copilot"
        # read-only shell commands
        "--allow-tool='shell(ls)'"
        "--allow-tool='shell(cat)'"
        "--allow-tool='shell(head)'"
        "--allow-tool='shell(tail)'"
        "--allow-tool='shell(grep)'"
        "--allow-tool='shell(find)'"
        "--allow-tool='shell(wc)'"
        "--allow-tool='write'"
        # git read-only ops (write ops like push/commit/merge will prompt)
        "--allow-tool='shell(git status)'"
        "--allow-tool='shell(git log)'"
        "--allow-tool='shell(git diff)'"
        "--allow-tool='shell(git show)'"
        "--allow-tool='shell(git branch)'"
        "--allow-tool='shell(git fetch)'"
        "--allow-tool='shell(git remote)'"
        "--allow-tool='shell(git tag)'"
        "--allow-tool='shell(git stash)'"
        "--allow-tool='shell(git rev-parse)'"
        "--allow-tool='shell(git ls-files)'"
        "--allow-tool='shell(git blame)'"
        "--allow-tool='shell(git config)'"
        "--allow-tool='shell(git shortlog)'"
        # gh read-only ops (create/merge/close/comment will prompt)
        "--allow-tool='shell(gh pr list)'"
        "--allow-tool='shell(gh pr view)'"
        "--allow-tool='shell(gh pr diff)'"
        "--allow-tool='shell(gh pr status)'"
        "--allow-tool='shell(gh pr checks)'"
        "--allow-tool='shell(gh issue list)'"
        "--allow-tool='shell(gh issue view)'"
        "--allow-tool='shell(gh issue status)'"
        "--allow-tool='shell(gh repo view)'"
        "--allow-tool='shell(gh repo list)'"
        "--allow-tool='shell(gh run list)'"
        "--allow-tool='shell(gh run view)'"
      ];
    };

    sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
    };

    initContent = ''
      # Environment
      export GOENV_ROOT="$HOME/.goenv"
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#888888"

      # PATH
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/dotfiles/bun/node_modules/.bin:$PATH"
      export PATH="$GOENV_ROOT/bin:$PATH"
      export PATH="$GOENV_ROOT/shims:$PATH"
      export PATH="$HOME/.volta/bin:$PATH"
      export PATH="$HOME/.tgenv/bin:$PATH"
      export PATH="$HOME/.tfenv/bin:$PATH"
      if [ -d /opt/podman/bin ]; then
        export PATH="/opt/podman/bin:$PATH"
      fi
      export PATH="$PATH:$HOME/.lmstudio/bin"
      export PATH="$HOME/.bun/bin:$PATH"

      # goenv (only if installed)
      if command -v goenv &>/dev/null; then
        eval "$(goenv init -)"
      fi

      # Google Cloud SDK
      if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
      if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

      # AWS completion
      if command -v aws_completer &>/dev/null; then
        fpath=($fpath ~/.zsh/completion)
        autoload bashcompinit && bashcompinit
        complete -C "$(command -v aws_completer)" aws
      fi

      # GitHub CLI completion
      eval "$(gh completion -s zsh)"

      # Prompt (vcs_info)
      autoload -Uz vcs_info
      setopt prompt_subst
      zstyle ':vcs_info:git:*' check-for-changes true
      zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
      zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
      zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
      zstyle ':vcs_info:*' actionformats '[%b|%a]'
      PROMPT="%n@%m %c\$vcs_info_msg_0_ %# "
      precmd(){ vcs_info }
    '';
  };
}
