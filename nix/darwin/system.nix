{
  pkgs,
  username,
  ...
}:

let
  dotnet-sdk = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnet-sdk_8
    pkgs.dotnetCorePackages.sdk_10_0-bin
  ];
in
{
  launchd.user.envVariables = {
    DOTNET_ROOT = "${dotnet-sdk}/share/dotnet";
    DOTNET_ROOT_ARM64 = "${dotnet-sdk}/share/dotnet";
  };

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

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew.enable = false;
}
