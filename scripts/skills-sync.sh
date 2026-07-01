#!/usr/bin/env bash
# Symlink each skill under dotfiles/skills/<name> into every supported
# tool's skills directory (Claude / Codex / GitHub Copilot CLI), one
# symlink per skill (not a whole-directory symlink). This lets
# work-only/private skills live directly under a tool's skills dir as a
# real directory, untouched by this repo, while dotfiles-managed skills
# stay in sync across tools.

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
DOTFILES_SKILLS_DIR="$SCRIPT_DIR/skills"

TARGET_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.copilot/skills"
)

usage() {
  cat <<EOF
Usage: $0 [options]

Symlink each skill in $DOTFILES_SKILLS_DIR into:
$(printf '  - %s\n' "${TARGET_DIRS[@]}")

A skill whose target already exists as a real (non-symlink) directory is
treated as a local/private skill and left untouched, unless --force is
given. Stale symlinks that point back into $DOTFILES_SKILLS_DIR for a
skill that no longer exists there are removed automatically.

Options:
  -h, --help   Show this help message
  --force      Replace real directories at the target with a symlink
EOF
}

FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --force) FORCE=1; shift ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [ ! -d "$DOTFILES_SKILLS_DIR" ]; then
  echo "No skills directory found at $DOTFILES_SKILLS_DIR" >&2
  exit 1
fi

echo "==> Syncing skills from $DOTFILES_SKILLS_DIR"

shopt -s nullglob
for skill_path in "$DOTFILES_SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_path")"
  skill_src="${skill_path%/}"

  for target_dir in "${TARGET_DIRS[@]}"; do
    mkdir -p "$target_dir"
    target="$target_dir/$skill_name"

    if [ -L "$target" ]; then
      if [ "$(readlink "$target")" = "$skill_src" ]; then
        echo "    [$skill_name] $target: ✓"
      else
        echo "    [$skill_name] $target: relinking (was -> $(readlink "$target"))"
        rm -f "$target"
        ln -s "$skill_src" "$target"
      fi
    elif [ -e "$target" ]; then
      if [ "$FORCE" = "1" ]; then
        echo "    [$skill_name] $target: real directory found, --force replacing with symlink"
        rm -rf "$target"
        ln -s "$skill_src" "$target"
      else
        echo "    [$skill_name] $target: SKIP (real directory exists — looks like a local/private skill; use --force or scripts/skills-promote.sh $skill_name to move it into dotfiles)" >&2
      fi
    else
      echo "    [$skill_name] $target: linking"
      ln -s "$skill_src" "$target"
    fi
  done
done

# Prune dangling symlinks left behind by skills removed from dotfiles.
for target_dir in "${TARGET_DIRS[@]}"; do
  [ -d "$target_dir" ] || continue
  for link in "$target_dir"/*; do
    [ -L "$link" ] || continue
    dest="$(readlink "$link")"
    case "$dest" in
      "$DOTFILES_SKILLS_DIR"/*)
        if [ ! -e "$dest" ]; then
          echo "    Removing stale link: $link -> $dest"
          rm -f "$link"
        fi
        ;;
    esac
  done
done

echo "✅ Skills sync complete."
