# dotfiles

macOS (aarch64-darwin) 環境を Nix (nix-darwin + home-manager) で管理する dotfiles。

## セットアップ

```bash
git clone git@github.com:arairyus/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` は以下を実行する:

1. Nix インストール (Determinate Systems)
2. nix-darwin + home-manager ビルド & 適用
3. Nix 外ツールのインストール (GitHub Copilot CLI, goenv)
4. Neovim 設定の symlink

## 構造

```
flake.nix                  # エントリポイント
nix/
  hosts/MBA-M2/            # ホスト固有設定 (ない場合は auto で自動検出)
  darwin/                   # macOS システム設定 (Dock, Finder, キーボード等)
  home/                     # home-manager モジュール
    packages.nix            # パッケージ一覧
    zsh.nix                 # シェル設定
    git.nix                 # Git 設定
config/
  nvim/                     # Neovim 設定 (LazyVim)
  cmux/                     # cmux (Ghostty) 設定
setup.sh                   # ブートストラップスクリプト
```

## 設定変更の適用

```bash
./setup.sh
```
