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
                "derailed/k9s"
                "goodwithtech/r"
                "kong/deck"
                "kreuzwerker/taps"
                "microsoft/mssql-release"
                "powershell/tap"
                "weaveworks/tap"
              ];

              brews = [
                "actionlint"
                "ansible"
                "ansible-lint"
                "aquasecurity/trivy/trivy"
                "argocd"
                "atlassian/acli/acli"
                "awscli"
                "aws-sam-cli"
                "azure-cli"
                "azure/azd/azd"
                "azure/functions/azure-functions-core-tools@4"
                "azcopy"
                "bat"
                "cfn-lint"
                "checkov"
                "codex"
                "composer"
                "cookiecutter"
                "coreutils"
                "derailed/k9s/k9s"
                "direnv"
                "docutils"
                "fd"
                "flake8"
                "fzf"
                "gh"
                "ghostscript"
                "git-filter-repo"
                "git-secrets"
                "gitleaks"
                "goenv"
                "golangci-lint"
                "goodwithtech/r/dockle"
                "graphviz"
                "hadolint"
                "helm"
                "httpie"
                "imagemagick"
                "infracost"
                "jq"
                "kong/deck/deck"
                "kreuzwerker/taps/m1-terraform-provider-helper"
                "kubectx"
                "kustomize"
                "lastpass-cli"
                "lazygit"
                "localstack"
                "microsoft/mssql-release/mssql-tools18"
                "minikube"
                "mtr"
                "mysql-client"
                "neovim"
                "newrelic-cli"
                "node"
                "nodenv"
                "pipx"
                "poetry"
                "postgresql@14"
                "powershell/tap/powershell"
                "pre-commit"
                "pyenv"
                "python-markdown"
                "python@3.10"
                "python@3.11"
                "python@3.8"
                "rbenv"
                "rustup"
                "shellcheck"
                "sl"
                "terraform-docs"
                "terrascan"
                "tfcmt"
                "tfenv"
                "tflint"
                "tfsec"
                "tmux"
                "tree"
                "vegeta"
                "volta"
                "weaveworks/tap/eksctl"
                "wget"
                "yq"
                "zsh-autosuggestions"
                "zsh-completions"
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

              programs.zsh = {
                enable = true;
              };
            };
          }
        ];
      };
    };
  };
}
