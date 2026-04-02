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
}
