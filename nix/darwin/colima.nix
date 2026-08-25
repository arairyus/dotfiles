{ pkgs, ... }:

{
  # Start the default Colima VM at login.
  # LaunchAgent (login), not LaunchDaemon (boot) — colima needs a user session
  # and the user's Nix profile PATH to find lima/qemu/vz binaries.
  # AbandonProcessGroup is required: `colima start` exits once the VM is up.
  # KeepAlive must stay off or launchd will restart-loop.
  launchd.user.agents.colima = {
    serviceConfig = {
      Label = "com.colima.default";
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
      ];
      EnvironmentVariables = {
        PATH = "${pkgs.docker-client}/bin:${pkgs.lima}/bin:${pkgs.colima}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      AbandonProcessGroup = true;
      StandardOutPath = "/tmp/colima.log";
      StandardErrorPath = "/tmp/colima.err";
    };
  };
}
