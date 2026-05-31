#!/usr/bin/env bash

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

usage() {
  cat <<EOF
Usage: $0 [options]

Apply Nix-managed dotfiles changes.

Options:
  -h, --help        Show this help message
  --hostname SHORT  Override hostname (default: derived from system)

Environment variables:
  TRACE=1           Enable script tracing
EOF
}

HOSTNAME_SHORT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --hostname)
      HOSTNAME_SHORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$HOSTNAME_SHORT" ]]; then
  HOSTNAME_SHORT="$(hostname -s)"
fi

echo "==> Applying dotfiles for host: $HOSTNAME_SHORT"
echo "    directory: $SCRIPT_DIR"
echo "    OS: $(uname)"

if ! command -v nix &>/dev/null; then
  echo "Nix is not installed. Run ./setup.sh first." >&2
  exit 1
fi

OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
  DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"
  FLAKE_TARGET="$SCRIPT_DIR#auto"
  EXTRA_FLAGS="--impure"

  if [ -x "$DARWIN_REBUILD" ]; then
    echo "==> Rebuilding nix-darwin..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo -H --preserve-env=HOSTNAME_SHORT,USERNAME \
      "$DARWIN_REBUILD" switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  else
    echo "==> Bootstrapping nix-darwin (first run)..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo -H --preserve-env=HOSTNAME_SHORT,USERNAME \
      nix run nix-darwin -- switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  fi
else
  HM_CONFIG="${HM_CONFIG:-codespaces}"
  echo "==> Building home-manager (config: $HM_CONFIG)..."

  if ! command -v home-manager &>/dev/null; then
    echo "    Installing home-manager..."
    nix run home-manager -- switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  else
    home-manager switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  fi
fi

echo ""
echo "✅ Apply complete! Open a new terminal to apply changes."
