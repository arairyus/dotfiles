{ ... }:

let
  shellAliases = import ./shell-aliases.nix;
in

{
  programs.bash = {
    enable = true;
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

    inherit shellAliases;

    sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
      USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
    };

    initExtra = ''
      # Environment
      export GOENV_ROOT="$HOME/.goenv"

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
      if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then . "$HOME/google-cloud-sdk/path.bash.inc"; fi
      if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then . "$HOME/google-cloud-sdk/completion.bash.inc"; fi

      # AWS completion
      if command -v aws_completer &>/dev/null; then
        complete -C "$(command -v aws_completer)" aws
      fi

      # GitHub CLI completion
      eval "$(gh completion -s bash)"

      # Prompt (git branch/status)
      __nix_bash_git_prompt() {
        local branch status
        branch="$(git branch --show-current 2>/dev/null)" || return 0
        [ -n "$branch" ] || return 0
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          status="+"
        fi
        printf ' [%s%s]' "$branch" "$status"
      }
      PS1='\u@\h \W$(__nix_bash_git_prompt) \$ '
    '';
  };
}
