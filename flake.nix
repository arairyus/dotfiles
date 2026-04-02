{
  description = "ryusei's dotfiles — managed by Nix (macOS + Linux)";

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

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      mba-m2 = import ./nix/hosts/MBA-M2 { inherit inputs; };
    in
    {
      # macOS (nix-darwin + home-manager)
      darwinConfigurations = {
        ${mba-m2.hostname} = mba-m2.darwinConfiguration;
      };

      # Linux / Codespaces (standalone home-manager)
      homeConfigurations = {
        "codespaces" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [
            ./nix/home
            {
              home.username = "codespace";
              home.homeDirectory = "/home/codespace";
            }
          ];
        };
      };
    };
}
