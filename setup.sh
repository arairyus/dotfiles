#!/usr/bin/env bash

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

usage() {
  cat <<EOF
Usage: $0 [options]

Bootstrap this machine, apply Nix-managed dotfiles, and install tools outside Nix.
For day-to-day Nix changes, use ./apply.sh.

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

OS="$(uname)"

# ----------------------------------------------------------
# 2. System build (OS-dependent)
# ----------------------------------------------------------
"$SCRIPT_DIR/apply.sh" --hostname "$HOSTNAME_SHORT"

# ----------------------------------------------------------
# 3. Post-setup: tools outside Nix
# ----------------------------------------------------------
echo "==> Post-setup..."

# Ensure nix-managed tools are in PATH (setup.sh doesn't source .zprofile)
ACTUAL_USER="${SUDO_USER:-$USER}"
export PATH="/etc/profiles/per-user/$ACTUAL_USER/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH"

# Run commands as the actual user.
# If setup.sh was invoked via sudo, drop back to the original user.
# If invoked directly (no sudo), run as-is to preserve PATH.
if [[ "$OS" == "Darwin" ]] && [[ -n "${SUDO_USER:-}" ]]; then
  RUN_AS="sudo -u $SUDO_USER"
else
  RUN_AS=""
fi

# GitHub Copilot CLI
# ~/.local/bin is already in PATH via zsh.nix, so answer "N" to the PATH prompt
# shellcheck disable=SC2016
if ! $RUN_AS bash -c 'test -x "${HOME}/.local/bin/copilot"' 2>/dev/null; then
  echo "    Installing GitHub Copilot CLI..."
  $RUN_AS bash -c '
    curl -fsSL https://gh.io/copilot-install -o /tmp/_copilot_install.sh
    echo N | bash /tmp/_copilot_install.sh
    rm -f /tmp/_copilot_install.sh
  '
else
  echo "    GitHub Copilot CLI: ✓"
fi

# GitHub Copilot CLI user-level hooks
COPILOT_NOTIFY_SCRIPT="$SCRIPT_DIR/scripts/copilot-notify.sh"
COPILOT_HOOKS_SRC="$SCRIPT_DIR/config/copilot/hooks/copilot-notifications.json"
COPILOT_HOOKS_DIR="$HOME/.copilot/hooks"
COPILOT_HOOKS_DST="$COPILOT_HOOKS_DIR/copilot-notifications.json"
if [ -f "$COPILOT_HOOKS_SRC" ] && [ -f "$COPILOT_NOTIFY_SCRIPT" ]; then
  $RUN_AS mkdir -p "$COPILOT_HOOKS_DIR"
  $RUN_AS chmod +x "$COPILOT_NOTIFY_SCRIPT"
  if [ ! -L "$COPILOT_HOOKS_DST" ] || [ "$(readlink "$COPILOT_HOOKS_DST")" != "$COPILOT_HOOKS_SRC" ]; then
    echo "    Linking Copilot CLI hooks..."
    $RUN_AS rm -f "$COPILOT_HOOKS_DST"
    $RUN_AS ln -sf "$COPILOT_HOOKS_SRC" "$COPILOT_HOOKS_DST"
  else
    echo "    Copilot CLI hooks: ✓"
  fi
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
  BUN_STAMP="$BUN_DIR/node_modules/.dotfiles-install.sha256"
  BUN_INPUT_HASH="$(
    cd "$BUN_DIR"
    {
      shasum -a 256 package.json
      [ -f bun.lock ] && shasum -a 256 bun.lock
      [ -f bun.lockb ] && shasum -a 256 bun.lockb
    } | shasum -a 256 | awk '{print $1}'
  )"

  if [ -n "${FORCE_BUN_INSTALL:-}" ] || [ ! -d "$BUN_DIR/node_modules" ] || [ ! -f "$BUN_STAMP" ] || [ "$(cat "$BUN_STAMP")" != "$BUN_INPUT_HASH" ]; then
    echo "    Installing bun global packages..."
    $RUN_AS bash -c "cd '$BUN_DIR' && bun install --frozen-lockfile && mkdir -p node_modules && printf '%s\n' '$BUN_INPUT_HASH' > node_modules/.dotfiles-install.sha256"
  else
    echo "    bun global packages: ✓"
  fi
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

  # Ghostty config (cmux uses Ghostty engine)
  GHOSTTY_SRC="$SCRIPT_DIR/config/cmux/config"
  GHOSTTY_DST="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  GHOSTTY_DIR="$(dirname "$GHOSTTY_DST")"
  if [ -f "$GHOSTTY_SRC" ]; then
    mkdir -p "$GHOSTTY_DIR"
    if [ ! -L "$GHOSTTY_DST" ] || [ "$(readlink "$GHOSTTY_DST")" != "$GHOSTTY_SRC" ]; then
      echo "    Linking ghostty config..."
      rm -f "$GHOSTTY_DST"
      ln -sf "$GHOSTTY_SRC" "$GHOSTTY_DST"
    else
      echo "    ghostty config: ✓"
    fi
  fi
fi

# Skills (Claude / Codex / GitHub Copilot CLI)
if [ -x "$SCRIPT_DIR/scripts/skills-sync.sh" ]; then
  echo "==> Linking skills..."
  $RUN_AS "$SCRIPT_DIR/scripts/skills-sync.sh"
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
