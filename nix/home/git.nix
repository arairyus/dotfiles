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
      core = {
        editor = "nvim";
        hooksPath = "~/.config/git/hooks";
      };

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

  # Global pre-commit hook for all repositories/worktrees.
  # Ensures Terraform files are always formatted before commit.
  home.file.".config/git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if ! command -v terraform >/dev/null 2>&1; then
        echo "[pre-commit] terraform command not found" >&2
        exit 1
      fi

      mapfile -t tf_files < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.tf$|\.tfvars$' || true)
      if [ ''${#tf_files[@]} -eq 0 ]; then
        exit 0
      fi

      echo "[pre-commit] running terraform fmt -recursive"
      terraform fmt -recursive

      for f in "''${tf_files[@]}"; do
        if [ -e "$f" ]; then
          git add "$f"
        fi
      done
    '';
  };
}
