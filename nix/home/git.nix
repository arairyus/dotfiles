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

  # Global pre-commit dispatcher for all repositories/worktrees.
  # If a repository has .pre-commit-config.yaml, prefer repository pre-commit hooks.
  # Otherwise, fallback to Terraform formatting.
  home.file.".config/git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
      if [ -n "$repo_root" ] && [ -f "$repo_root/.pre-commit-config.yaml" ]; then
        if ! command -v pre-commit >/dev/null 2>&1; then
          echo "[pre-commit] pre-commit command not found" >&2
          exit 1
        fi

        mapfile -t staged_files < <(git diff --cached --name-only --diff-filter=ACMR || true)
        if [ ''${#staged_files[@]} -eq 0 ]; then
          exit 0
        fi

        echo "[pre-commit] running repository pre-commit hooks"
        pre-commit run --hook-stage pre-commit --files "''${staged_files[@]}"
        exit 0
      fi

      mapfile -t tf_files < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.tf$|\.tfvars$' || true)
      if [ ''${#tf_files[@]} -eq 0 ]; then
        exit 0
      fi

      if ! command -v terraform >/dev/null 2>&1; then
        echo "[pre-commit] terraform command not found" >&2
        exit 1
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

  # Dispatch commit-msg hook to repository pre-commit when configured.
  home.file.".config/git/hooks/commit-msg" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
      if [ -z "$repo_root" ] || [ ! -f "$repo_root/.pre-commit-config.yaml" ]; then
        exit 0
      fi

      if ! command -v pre-commit >/dev/null 2>&1; then
        echo "[commit-msg] pre-commit command not found" >&2
        exit 1
      fi

      if [ "$#" -lt 1 ]; then
        echo "[commit-msg] commit message file path is required" >&2
        exit 1
      fi

      pre-commit run --hook-stage commit-msg --commit-msg-filename "$1"
    '';
  };
}
