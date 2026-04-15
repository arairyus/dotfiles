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
      # Darwin config factory — requires: nix ... --impure
      # HOSTNAME_SHORT and USERNAME must be set in the environment.
      mkDarwinConfig =
        {
          hostname,
          username,
          system ? "aarch64-darwin",
        }:
        let
          homedir = "/Users/${username}";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        inputs.nix-darwin.lib.darwinSystem {
          inherit system pkgs;
          specialArgs = { inherit username homedir; };
          modules =
            (import ./nix/darwin {
              inherit username homedir;
            }).modules
            ++ [
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "bak";
                home-manager.users.${username} = {
                  imports = [ ./nix/home ];
                  home.username = username;
                  home.homeDirectory = homedir;
                };
              }
            ];
        };
    in
    {
      # macOS (nix-darwin + home-manager)
      darwinConfigurations = {
        auto = mkDarwinConfig {
          hostname = builtins.getEnv "HOSTNAME_SHORT";
          username = builtins.getEnv "USERNAME";
          system = builtins.currentSystem;
        };
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

        "devcontainer" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
          modules = [
            ./nix/home
            {
              home.username = "vscode";
              home.homeDirectory = "/home/vscode";
            }
          ];
        };
      };
    };
}
