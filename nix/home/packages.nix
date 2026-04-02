{ pkgs, ... }:

{
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
    kubectl
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
}
