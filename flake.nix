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

      # Generic darwin config factory (reused by named hosts and auto)
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
        ${mba-m2.hostname} = mba-m2.darwinConfiguration;

        # Fallback for any unregistered Mac — requires: nix ... --impure
        # USERNAME and HOSTNAME_SHORT must be set in the environment.
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
