---
name: nix-package-install
description: >
  Install a CLI tool via Nix into the user's dotfiles (~/dotfiles).
  Use when the user provides a URL (GitHub repo, homepage, etc.) and wants to add a package to their Nix-managed environment.
  Also use when the user asks to "nix install", "add to dotfiles", or "add a tool via nix".
---

# Nix Package Install Skill

The user manages their development environment declaratively with **Nix Flakes** in `~/dotfiles`.

## Repository layout

```
~/dotfiles/
├── flake.nix                  # Flake entry point (nix-darwin + home-manager)
├── nix/
│   ├── darwin/                # macOS (nix-darwin) modules
│   └── home/
│       ├── default.nix        # home-manager entry
│       ├── packages.nix       # ← package list lives here
│       ├── git.nix
│       └── zsh.nix
```

## Workflow

When the user provides a URL or tool name:

### 1. Identify the tool

Extract the tool name from the URL or user input (e.g., `https://github.com/cli/cli` → `gh`).

### 2. Search nixpkgs

Check if the package exists in nixpkgs:

```bash
nix search nixpkgs#<package-name> --json 2>/dev/null | head -50
```

If the exact name doesn't match, try common variations (e.g., tool name, repo name, lowercase). Show the user the matching packages and confirm which one to install.

### 3. Check for duplicates

Read `~/dotfiles/nix/home/packages.nix` and verify the package is not already listed. If it is, inform the user and stop.

### 4. Add the package

Edit `~/dotfiles/nix/home/packages.nix`:
- Add the package attribute name (e.g., `ripgrep`) to the appropriate section
- Maintain alphabetical order within each section
- Add a brief inline comment describing the tool (matching existing style)
- If no existing section fits, add it to the most relevant one or create a comment header

### 5. Validate

フルビルド (`nix flake check`) は避け、**軽量バリデーション** を行う:

```bash
cd ~/dotfiles && ./validate-packages.sh
```

このスクリプトは `packages.nix` だけを nixpkgs に対して評価し、全パッケージ属性が解決できるか数秒で確認する。
フル評価（darwin-rebuild）はユーザーが `~/dotfiles/setup.sh` を実行する際に行われる。

もし `validate-packages.sh` が失敗したら、変更を revert してエラーを報告する。

### 6. Commit and push

```bash
cd ~/dotfiles
git add nix/home/packages.nix
git commit -m "feat(nix): add <package-name>"
git push
```

The commit message should follow the existing convention: `feat(nix): add <package-name>`.

## Important notes

- Always confirm with the user before committing/pushing
- If `nix search` returns multiple results, ask the user which one they want
- The `packages.nix` file uses `with pkgs;` so only the attribute name is needed (not `pkgs.xxx`)
- Keep the inline comment style consistent: `# short description`
