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
echo "    OS: $(uname)"

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
# 2. System build (OS-dependent)
# ----------------------------------------------------------
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
  # macOS: nix-darwin + home-manager
  DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"

  # Determine flake target: use named config if it exists, else fall back to "auto"
  # Known configs live under nix/hosts/<hostname>/
  if [ -d "$SCRIPT_DIR/nix/hosts/$HOSTNAME_SHORT" ]; then
    FLAKE_TARGET="$SCRIPT_DIR#$HOSTNAME_SHORT"
    EXTRA_FLAGS=""
  else
    echo "    No host config found for '$HOSTNAME_SHORT', using auto config (--impure)"
    FLAKE_TARGET="$SCRIPT_DIR#auto"
    EXTRA_FLAGS="--impure"
  fi

  if [ -x "$DARWIN_REBUILD" ]; then
    echo "==> Rebuilding nix-darwin..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo --preserve-env=HOSTNAME_SHORT,USERNAME \
      "$DARWIN_REBUILD" switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  else
    echo "==> Bootstrapping nix-darwin (first run)..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo --preserve-env=HOSTNAME_SHORT,USERNAME \
      nix run nix-darwin -- switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  fi
else
  # Linux / Codespaces: standalone home-manager
  HM_CONFIG="${HM_CONFIG:-codespaces}"
  echo "==> Building home-manager (config: $HM_CONFIG)..."

  if ! command -v home-manager &>/dev/null; then
    echo "    Installing home-manager..."
    nix run home-manager -- switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  else
    home-manager switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  fi
fi

# ----------------------------------------------------------
# 3. Post-setup: tools outside Nix
# ----------------------------------------------------------
echo "==> Post-setup..."

# Run commands as the actual user (macOS runs setup.sh via sudo)
if [[ "$OS" == "Darwin" ]]; then
  RUN_AS="sudo -u ${SUDO_USER:-$USER}"
else
  RUN_AS=""
fi

# GitHub Copilot CLI
if ! command -v copilot &>/dev/null; then
  echo "    Installing GitHub Copilot CLI..."
  $RUN_AS bash -c 'curl -fsSL https://gh.io/copilot-install | bash'
else
  echo "    GitHub Copilot CLI: ✓"
fi

# goenv
if [ ! -d "$HOME/.goenv" ]; then
  echo "    Installing goenv..."
  $RUN_AS git clone https://github.com/go-nv/goenv.git "$HOME/.goenv"
else
  echo "    goenv: ✓"
fi

# tfenv
if [ ! -d "$HOME/.tfenv" ]; then
  echo "    Installing tfenv..."
  $RUN_AS git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
else
  echo "    tfenv: ✓"
fi

# aws-sam-cli
if ! command -v sam &>/dev/null; then
  echo "    Installing aws-sam-cli..."
  $RUN_AS pipx install aws-sam-cli
else
  echo "    aws-sam-cli: ✓"
fi

# Bun global packages (from bun/package.json)
BUN_DIR="$SCRIPT_DIR/bun"
if [ -f "$BUN_DIR/package.json" ]; then
  echo "    Installing bun global packages..."
  $RUN_AS bash -c "cd $BUN_DIR && bun install --frozen-lockfile"
else
  echo "    bun/package.json not found, skipping"
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

# cmux config (symlink) - macOS only
if [[ "$OS" == "Darwin" ]]; then
  CMUX_SRC="$SCRIPT_DIR/config/cmux/config.ghostty"
  CMUX_DST="$HOME/Library/Application Support/com.cmuxterm.app/config.ghostty"
  CMUX_DIR="$(dirname "$CMUX_DST")"
  if [ -f "$CMUX_SRC" ]; then
    mkdir -p "$CMUX_DIR"
    if [ ! -L "$CMUX_DST" ] || [ "$(readlink "$CMUX_DST")" != "$CMUX_SRC" ]; then
      echo "    Linking cmux config..."
      rm -f "$CMUX_DST"
      ln -sf "$CMUX_SRC" "$CMUX_DST"
    else
      echo "    cmux config: ✓"
    fi
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
