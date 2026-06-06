{ ... }:

{
  # Takumi Guard (npm ecosystem)
  home.file.".npmrc".text = ''
    registry=https://npm.flatt.tech
  '';

  # pnpm also reads npm-compatible registry settings
  home.file.".config/pnpm/rc".text = ''
    registry=https://npm.flatt.tech
  '';

  # Yarn v2+ uses .yarnrc.yml for npm registry settings
  home.file.".yarnrc.yml".text = ''
    npmRegistryServer: "https://npm.flatt.tech"
  '';

  # bun registry settings
  home.file.".bunfig.toml".text = ''
    [install]
    registry = "https://npm.flatt.tech"
  '';
}
