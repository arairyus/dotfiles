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
        pl = "pull origin";
      };

      branch.sort = "-authordate";

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

      url."https://:@github.com".insteadOf = "https://github.com";
    };

    ignores = [
      ".claude/settings.local.json"
    ];
  };
}
