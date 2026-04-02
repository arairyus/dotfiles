{
  description = "ryusei's dotfiles — macOS environment managed by Nix";

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
      darwinConfigurations = {
        ${mba-m2.hostname} = mba-m2.darwinConfiguration;
      };
    };
}
