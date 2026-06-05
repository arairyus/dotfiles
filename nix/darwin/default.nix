{
  pkgs,
  username,
  homedir,
  ...
}:
{
  modules = [
    (import ./system.nix { inherit pkgs username; })
    (import ./users.nix { inherit username homedir; })
  ];
}
