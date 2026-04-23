{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "ryuseiarai";
        email = "arai.ryusei.jp@gmail.com";
      };

      alias = {
        push-f = "push --force-with-lease";
        sw = "switch";
        br = "branch";
        ci = "commit";
        st = "status";
        ad = "add";
        pl = "pull -p origin";
      };

      branch.sort = "-authordate";
      core.editor = "nvim";

      credential."https://github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
      credential."https://gist.github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
      credential."https://source.developers.google.com".helper = "gcloud.sh";
    };

    ignores = [
      # OS / editor junk
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      "*.orig"
      "*.rej"

      # Local-only settings
      ".claude/settings.local.json"
      ".direnv"
      "result"

      # devenv
      ".devenv*"
      "devenv.nix"
      "devenv.yaml"
      "devenv.lock"

      # terraform
      ".spec"
    ];
  };

  # git-cz (streamich/git-cz): disable emoji prefix in commit messages
  home.file.".git-cz.json".text = builtins.toJSON {
    disableEmoji = true;
  };
}
