#!/usr/bin/env bash
# GitHub Codespaces dotfiles install script
# Codespaces automatically runs this when the dotfiles repo is configured.
# See: https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account

set -euo pipefail
[ -n "${TRACE:-}" ] && set -x

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

exec "$SCRIPT_DIR/setup.sh" "$@"
