{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.nixfmt-rfc-style
  ];

  # https://devenv.sh/scripts/
  scripts.lint-all = {
    exec = "pre-commit run --all-files";
  };
  scripts.fmt-nix = {
    exec = "nixfmt nix/**/*.nix flake.nix devenv.nix";
  };

  # https://devenv.sh/languages/
  languages.nix.enable = true;
  languages.shell.enable = true;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nixfmt-rfc-style.enable = true;
  git-hooks.hooks.shellcheck.enable = true;
  git-hooks.hooks.shfmt.enable = true;
  git-hooks.hooks.actionlint.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
