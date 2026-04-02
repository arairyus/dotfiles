{
  inputs,
}:
let
  nix-root-dir = ../..;

  hostname = "MBA-M2";
  system = "aarch64-darwin";
  username = "ryusei";
  homedir = "/Users/${username}";

  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  inherit system hostname;

  darwinConfiguration = inputs.nix-darwin.lib.darwinSystem {
    inherit system pkgs;

    specialArgs = { inherit username homedir; };

    modules =
      (import "${nix-root-dir}/darwin" {
        inherit username homedir;
      }).modules
      ++ [
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.${username} = {
            imports = [
              "${nix-root-dir}/home"
            ];
            home.username = username;
            home.homeDirectory = homedir;
          };
        }
      ];
  };
}
