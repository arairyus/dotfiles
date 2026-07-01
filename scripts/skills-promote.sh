#!/usr/bin/env bash
# Promote a skill that was created/edited locally (e.g. by Claude, Codex,
# or GitHub Copilot CLI) into this dotfiles repo, then re-link it into
# every supported tool's skills directory.

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
DOTFILES_SKILLS_DIR="$SCRIPT_DIR/skills"

SOURCE_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.copilot/skills"
)

usage() {
  cat <<EOF
Usage: $0 <skill-name>

Look for a real (non-symlink) skill directory named <skill-name> under:
$(printf '  - %s/<skill-name>\n' "${SOURCE_DIRS[@]}")

The first one found is moved into $DOTFILES_SKILLS_DIR/<skill-name>, then
scripts/skills-sync.sh re-links it back into all tool skills directories
(including the one it was moved from).

Options:
  -h, --help   Show this help message
EOF
}

if [[ $# -eq 1 ]] && { [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; }; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

SKILL_NAME="$1"

case "$SKILL_NAME" in
  ""|.*|*/*)
    echo "Invalid skill name: '$SKILL_NAME'" >&2
    exit 1
    ;;
esac

DEST="$DOTFILES_SKILLS_DIR/$SKILL_NAME"
if [ -e "$DEST" ]; then
  echo "skills/$SKILL_NAME already exists in dotfiles ($DEST)." >&2
  echo "Run scripts/skills-sync.sh instead if you just need to (re-)link it." >&2
  exit 1
fi

FOUND=""
OTHER_MATCHES=()
for dir in "${SOURCE_DIRS[@]}"; do
  candidate="$dir/$SKILL_NAME"
  if [ -d "$candidate" ] && [ ! -L "$candidate" ]; then
    if [ -z "$FOUND" ]; then
      FOUND="$candidate"
    else
      OTHER_MATCHES+=("$candidate")
    fi
  fi
done

if [ -z "$FOUND" ]; then
  echo "No real (non-symlink) skill directory named '$SKILL_NAME' found under:" >&2
  printf '  %s\n' "${SOURCE_DIRS[@]}" >&2
  exit 1
fi

echo "==> Promoting $FOUND -> $DEST"
mkdir -p "$DOTFILES_SKILLS_DIR"
mv "$FOUND" "$DEST"

if [ "${#OTHER_MATCHES[@]}" -gt 0 ]; then
  echo "    Note: other real directories named '$SKILL_NAME' also existed and were left as-is:" >&2
  printf '      %s\n' "${OTHER_MATCHES[@]}" >&2
  echo "    They will be reported by skills-sync.sh as conflicting with the newly promoted skill." >&2
fi

echo "==> Re-linking skills"
"$SCRIPT_DIR/scripts/skills-sync.sh"

echo ""
echo "✅ Promoted '$SKILL_NAME' into dotfiles. Review and commit:"
echo "   git -C \"$SCRIPT_DIR\" add skills/$SKILL_NAME"
