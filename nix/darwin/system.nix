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

  homebrew = {
    enable = true;
    # azure-cli: nixpkgs' k8s-extension fails to build (kubernetes/oras version
    # pin mismatch) and az extension add doesn't work against the Nix-bundled
    # python (no pip module). Manage azure-cli via Homebrew instead.
    brews = [ "azure-cli" ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
  };

  # Keep rg reachable from sandboxed tools that only check /usr/local/bin.
  system.activationScripts.ensureRgSymlink.text = ''
    if [ -x /etc/profiles/per-user/${username}/bin/rg ]; then
      mkdir -p /usr/local/bin
      ln -sfn /etc/profiles/per-user/${username}/bin/rg /usr/local/bin/rg
    fi
  '';
}
