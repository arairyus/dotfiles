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
  --force           Rebuild even if Nix config files are unchanged

Environment variables:
  TRACE=1           Enable script tracing
  FORCE_APPLY=1     Rebuild even if Nix config files are unchanged
  DOTFILES_DARWIN_CONFIG
                    Override nix-darwin flake config (default: hostname)
EOF
}

HOSTNAME_SHORT=""
FORCE_APPLY="${FORCE_APPLY:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --hostname)
      HOSTNAME_SHORT="$2"; shift 2 ;;
    --force)
      FORCE_APPLY=1; shift ;;
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

nix_config_hash() {
  (
    cd "$SCRIPT_DIR"
    {
      [ -f flake.nix ] && shasum -a 256 flake.nix
      [ -f flake.lock ] && shasum -a 256 flake.lock
      if [ -d nix ]; then
        find nix -type f | LC_ALL=C sort | while IFS= read -r file; do
          shasum -a 256 "$file"
        done
      fi
    } | shasum -a 256 | awk '{print $1}'
  )
}

apply_cache_file() {
  local key safe_key cache_dir
  key="$1"
  safe_key="$(printf '%s' "$key" | tr -c 'A-Za-z0-9_.-' '_')"
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
  mkdir -p "$cache_dir"
  printf '%s/apply-%s.sha256\n' "$cache_dir" "$safe_key"
}

skip_if_unchanged() {
  local key config_hash stamp_file
  key="$1"
  config_hash="$2"
  stamp_file="$(apply_cache_file "$key")"

  if [ -z "$FORCE_APPLY" ] && [ -f "$stamp_file" ] && [ "$(cat "$stamp_file")" = "$config_hash" ]; then
    echo "==> Nix config unchanged; skipping rebuild."
    echo "    Use --force or FORCE_APPLY=1 to rebuild anyway."
    exit 0
  fi
}

mark_applied() {
  local key config_hash stamp_file
  key="$1"
  config_hash="$2"
  stamp_file="$(apply_cache_file "$key")"
  printf '%s\n' "$config_hash" > "$stamp_file"
}

OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
  DARWIN_REBUILD="/run/current-system/sw/bin/darwin-rebuild"
  DARWIN_CONFIG="${DOTFILES_DARWIN_CONFIG:-$HOSTNAME_SHORT}"
  APPLY_CACHE_KEY="darwin-$DARWIN_CONFIG"
  APPLY_HASH="$(nix_config_hash)"

  if grep -Fq "\"$DARWIN_CONFIG\" = mkDarwinConfig" "$SCRIPT_DIR/flake.nix"; then
    FLAKE_TARGET="$SCRIPT_DIR#$DARWIN_CONFIG"
    EXTRA_FLAGS=""
  else
    FLAKE_TARGET="$SCRIPT_DIR#auto"
    EXTRA_FLAGS="--impure"
    echo "    No pure darwin config for '$DARWIN_CONFIG'; falling back to impure #auto."
  fi

  skip_if_unchanged "$APPLY_CACHE_KEY" "$APPLY_HASH"

  if [ -x "$DARWIN_REBUILD" ]; then
    echo "==> Rebuilding nix-darwin ($FLAKE_TARGET)..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo -H --preserve-env=HOSTNAME_SHORT,USERNAME \
      "$DARWIN_REBUILD" switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  else
    echo "==> Bootstrapping nix-darwin (first run, $FLAKE_TARGET)..."
    # shellcheck disable=SC2086
    HOSTNAME_SHORT="$HOSTNAME_SHORT" USERNAME="$USER" \
      sudo -H --preserve-env=HOSTNAME_SHORT,USERNAME \
      nix run nix-darwin -- switch --flake "$FLAKE_TARGET" $EXTRA_FLAGS
  fi

  mark_applied "$APPLY_CACHE_KEY" "$APPLY_HASH"
else
  HM_CONFIG="${HM_CONFIG:-codespaces}"
  APPLY_CACHE_KEY="home-$HM_CONFIG"
  APPLY_HASH="$(nix_config_hash)"
  echo "==> Building home-manager (config: $HM_CONFIG)..."

  skip_if_unchanged "$APPLY_CACHE_KEY" "$APPLY_HASH"

  if ! command -v home-manager &>/dev/null; then
    echo "    Installing home-manager..."
    nix run home-manager -- switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  else
    home-manager switch --flake "$SCRIPT_DIR#$HM_CONFIG" -b bak
  fi

  mark_applied "$APPLY_CACHE_KEY" "$APPLY_HASH"
fi

echo ""
echo "✅ Apply complete! Open a new terminal to apply changes."
