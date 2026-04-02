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
              enable = true;

              taps = [
                "aquasecurity/trivy"
                "atlassian/acli"
                "azure/azd"
                "azure/functions"
                "goodwithtech/r"
                "kong/deck"
                "kreuzwerker/taps"
                "microsoft/mssql-release"
                "powershell/tap"
              ];

              brews = [
                # Cloud & Infra CLI (Homebrew-specific taps or better managed here)
                "aquasecurity/trivy/trivy"
                "atlassian/acli/acli"
                "awscli"
                "aws-sam-cli"
                "azure-cli"
                "azure/azd/azd"
                "azure/functions/azure-functions-core-tools@4"
                "azcopy"
                "cfn-lint"
                "codex"
                "goodwithtech/r/dockle"
                "kong/deck/deck"
                "kreuzwerker/taps/m1-terraform-provider-helper"
                "localstack"
                "microsoft/mssql-release/mssql-tools18"
                "newrelic-cli"
                "powershell/tap/powershell"

                # Version managers (need Homebrew for proper env integration)
                "goenv"
                "nodenv"
                "pyenv"
                "rbenv"
                "tfenv"
                "volta"

                # Language-specific tools (Homebrew versions better for compat)
                "ansible"
                "ansible-lint"
                "checkov"
                "composer"
                "cookiecutter"
                "docutils"
                "flake8"
                "lastpass-cli"
                "mysql-client"
                "node"
                "pipx"
                "poetry"
                "postgresql@14"
                "pre-commit"
                "python-markdown"
                "python@3.10"
                "python@3.11"
                "python@3.8"
                "rustup"
              ];

              casks = [
                "1password-cli"
                "ghostty"
                "inso"
                "session-manager-plugin"
                "slite"
              ];
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

                # direnv
                direnv
              ];

              programs.zsh = {
                enable = true;
                autosuggestion.enable = true;
                enableCompletion = true;

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
                  export PATH="$PATH:/Users/ryusei/.lmstudio/bin"

                  # goenv
                  eval "$(goenv init -)"

                  # Google Cloud SDK
                  if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
                  if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

                  # AWS
                  export PATH=/usr/local/bin/aws_completer:$PATH
                  fpath=($fpath ~/.zsh/completion)
                  autoload bashcompinit && bashcompinit
                  complete -C '/usr/local/bin/aws_completer' aws

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
