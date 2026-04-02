{
  username,
  homedir,
  ...
}:
{
  modules = [
    (import ./system.nix { inherit username; })
    (import ./users.nix { inherit username homedir; })
  ];
}
