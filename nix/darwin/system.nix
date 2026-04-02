{ username, ... }:

{
  system = {
    stateVersion = 5;
    primaryUser = username;

    defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
      };

      controlcenter = {
        BatteryShowPercentage = true;
      };

      loginwindow = {
        GuestEnabled = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  nix.enable = false; # Determinate Nix manages its own daemon

  homebrew.enable = false;
}
