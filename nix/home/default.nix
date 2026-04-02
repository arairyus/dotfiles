{ ... }:

{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
  ];

  home.stateVersion = "25.05";

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.local/bin"
  ];

  # direnv: auto-activate devenv when entering project directories
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
