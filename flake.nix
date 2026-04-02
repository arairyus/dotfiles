{
  description = "My macOS environment managed by Nix";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
  }:
  let
    hostname = "MBA-M2";
    username = "ryusei";
    system = "aarch64-darwin";
    homedir = "/Users/${username}";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    darwinConfigurations = {
      "${hostname}" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;

        modules = [
          {
            system = {
              stateVersion = 5;
              primaryUser = username;
            };

            nix.enable = false;

            users.users."${username}" = {
              home = homedir;
            };

            homebrew = {
              enable = false;
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users."${username}" = {
              home.stateVersion = "25.05";
              home.username = username;
              home.homeDirectory = homedir;

              home.packages = with pkgs; [
                # CLI utilities
                actionlint
                bat
                coreutils
                fd
                fzf
                gh
                ghostscript
                graphviz
                httpie
                imagemagick
                jq
                lazygit
                mtr
                neovim
                shellcheck
                sl
                tmux
                tree
                vegeta
                wget
                yq

                # Git tools
                git-filter-repo
                git-secrets
                gitleaks

                # Kubernetes & DevOps
                argocd
                eksctl
                hadolint
                kubernetes-helm
                infracost
                k9s
                kubectx
                kustomize
                minikube

                # IaC / Terraform
                golangci-lint
                terraform-docs
                terrascan
                tflint
                tfsec

                # Cloud CLIs
                awscli2
                azure-cli
                azure-storage-azcopy
                trivy
                checkov
                ssm-session-manager-plugin

                # Languages & version managers
                ansible
                ansible-lint
                nodejs
                nodenv
                pyenv
                rbenv
                rustup
                volta
                pipx
                poetry
                pre-commit
                cookiecutter
                lastpass-cli
                postgresql_14

                # 1Password CLI
                _1password-cli

                # Other
                direnv
                powershell
              ];

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
                  docker = "podman";
                  docker-compose = "podman compose";
                  dk = "podman";
                  ll = "ls -l";
                  la = "ls -al";
                  k = "kubectl";
                };

                sessionVariables = {
                  GOENV_ROOT = "$HOME/.goenv";
                  VOLTA_HOME = "$HOME/.volta";
                  USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
                };

                initContent = ''
                  # PATH
                  export PATH="$HOME/.local/bin:$PATH"
                  export PATH="$GOENV_ROOT/shims:$PATH"
                  export PATH="$HOME/.volta/bin:$PATH"
                  export PATH="$HOME/.tgenv/bin:$PATH"
                  export PATH="$PATH:$HOME/.lmstudio/bin"

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
            };
          }
        ];
      };
    };
  };
}
