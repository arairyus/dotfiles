#!/usr/bin/env bash

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -h, --help        Show this help message
  --hostname SHORT  Override hostname (default: derived from system)

Environment variables:
  TRACE=1           Enable script tracing
  SKIP_CLEAN=1      Skip nix store garbage collection
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

echo "==> dotfiles setup for host: $HOSTNAME_SHORT"
echo "    directory: $SCRIPT_DIR"

# ----------------------------------------------------------
# 1. Nix (Determinate Systems installer)
# ----------------------------------------------------------
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix (Determinate Systems)..."
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install
  echo "    Restart your shell and re-run this script."
  exit 0
fi

# ----------------------------------------------------------
# 2. nix-darwin build
# ----------------------------------------------------------
DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"

if [ -x "$DARWIN_REBUILD" ]; then
  echo "==> Rebuilding nix-darwin..."
  sudo "$DARWIN_REBUILD" switch --flake "$SCRIPT_DIR#$HOSTNAME_SHORT"
else
  echo "==> Bootstrapping nix-darwin (first run)..."
  sudo nix run nix-darwin -- switch --flake "$SCRIPT_DIR#$HOSTNAME_SHORT"
fi

# ----------------------------------------------------------
# 3. Post-setup: tools outside Nix (run as current user)
# ----------------------------------------------------------
echo "==> Post-setup..."

# GitHub Copilot CLI
if ! command -v copilot &>/dev/null; then
  echo "    Installing GitHub Copilot CLI..."
  sudo -u "${SUDO_USER:-$USER}" bash -c 'curl -fsSL https://gh.io/copilot-install | bash'
else
  echo "    GitHub Copilot CLI: ✓"
fi

# goenv
if [ ! -d "$HOME/.goenv" ]; then
  echo "    Installing goenv..."
  sudo -u "${SUDO_USER:-$USER}" git clone https://github.com/go-nv/goenv.git "$HOME/.goenv"
else
  echo "    goenv: ✓"
fi

# tfenv
if [ ! -d "$HOME/.tfenv" ]; then
  echo "    Installing tfenv..."
  sudo -u "${SUDO_USER:-$USER}" git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
else
  echo "    tfenv: ✓"
fi

# Neovim config (symlink)
NVIM_SRC="$SCRIPT_DIR/config/nvim"
NVIM_DST="$HOME/.config/nvim"
if [ -d "$NVIM_SRC" ]; then
  if [ ! -L "$NVIM_DST" ] || [ "$(readlink "$NVIM_DST")" != "$NVIM_SRC" ]; then
    echo "    Linking nvim config..."
    rm -rf "$NVIM_DST"
    ln -sf "$NVIM_SRC" "$NVIM_DST"
  else
    echo "    nvim config: ✓"
  fi
fi

# ----------------------------------------------------------
# 4. Cleanup
# ----------------------------------------------------------
if [ -z "${SKIP_CLEAN:-}" ]; then
  echo "==> Cleaning nix store..."
  nix store gc
fi

echo ""
echo "✅ Setup complete! Open a new terminal to apply changes."
