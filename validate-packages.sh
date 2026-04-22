#!/usr/bin/env bash
# Lightweight validation for packages.nix changes.
# Evaluates only the package list — no full darwin-rebuild needed.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "==> Validating packages.nix..."

COUNT=$(nix eval --impure --expr "
  let
    pkgs = import (builtins.getFlake \"nixpkgs\") {
      system = builtins.currentSystem;
      config.allowUnfree = true;
    };
    cfg = import $SCRIPT_DIR/nix/home/packages.nix { inherit pkgs; };
  in
    builtins.length cfg.home.packages
" 2>&1)

echo "✅ Valid — $COUNT packages resolved"
