{ pkgs, ... }:

let
  git-cz = pkgs.callPackage ../packages/git-cz { };
in

{
  home.packages = with pkgs; [
    # CLI utilities
    actionlint        # GitHub Actions workflow linter
    bat               # cat with syntax highlighting
    coreutils         # GNU core utilities
    devenv            # reproducible dev environments
    fd                # find alternative (fast, user-friendly)
    fzf               # fuzzy finder
    gh                # GitHub CLI
    ghostscript       # PostScript/PDF interpreter
    graphviz          # graph visualization (dot)
    httpie            # user-friendly HTTP client
    imagemagick       # image manipulation tools
    jq                # JSON processor
    lazygit           # terminal UI for git
    mtr               # network diagnostics (traceroute + ping)
    neovim            # modern vim
    pinact            # pin GitHub Actions versions
    shellcheck        # shell script linter
    tmux              # terminal multiplexer
    tree              # directory tree viewer
    vegeta            # HTTP load testing tool
    wget              # file downloader
    yq                # YAML/XML/TOML processor
    zizmor            # GitHub Actions security scanner

    # Git tools
    git-cz            # semantic emoji git commits
    git-filter-repo   # git history rewriting
    git-secrets       # prevent committing secrets
    gitleaks          # secret detection in git repos

    # Kubernetes & DevOps
    argocd            # Argo CD CLI (GitOps)
    eksctl            # Amazon EKS cluster management
    hadolint          # Dockerfile linter
    kubectl           # Kubernetes CLI
    kubernetes-helm   # Kubernetes package manager
    infracost         # cloud cost estimation for IaC
    k9s               # Kubernetes terminal UI
    kubectx           # switch kubectl context/namespace
    kustomize         # Kubernetes manifest customization
    minikube          # local Kubernetes cluster
    stern             # multi pod/container log tailing for Kubernetes

    # IaC / Terraform
    golangci-lint     # Go linter aggregator
    terraform-docs    # Terraform documentation generator
    vault             # HashiCorp Vault CLI
    terrascan         # IaC security scanner
    tflint            # Terraform linter
    tfsec             # Terraform security scanner

    # Cloud CLIs
    awscli2           # AWS CLI v2
    azure-cli         # Azure CLI
    azure-storage-azcopy # Azure storage data transfer
    trivy             # container/IaC vulnerability scanner
    checkov           # IaC security/compliance scanner
    ssm-session-manager-plugin # AWS Systems Manager session plugin

    # Languages & version managers
    ansible           # IT automation
    ansible-lint      # Ansible playbook linter
    bun               # JavaScript runtime & package manager
    nodejs            # Node.js runtime
    php               # PHP runtime
    nodenv            # Node.js version manager
    pyenv             # Python version manager
    rbenv             # Ruby version manager
    rustup            # Rust toolchain installer
    volta             # JavaScript tool manager
    pipx              # install Python CLI tools in isolation
    poetry            # Python dependency management
    pre-commit        # git pre-commit hook framework
    cookiecutter      # project template generator
    postgresql_14     # PostgreSQL 14

    # 1Password CLI
    _1password-cli    # 1Password CLI (op)

    # Other
    powershell        # PowerShell cross-platform
  ];
}
