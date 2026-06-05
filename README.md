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
3. Nix 外ツールのインストール (GitHub Copilot CLI, goenv, tfenv, aws-sam-cli)
4. Bun global packages のインストール (package.json / lockfile 変更時のみ)
5. Neovim / cmux / Ghostty 設定の symlink

## 構造

```
flake.nix                  # エントリポイント
nix/
  darwin/                   # macOS システム設定 (Dock, Finder, キーボード等)
  home/                     # home-manager モジュール
    packages.nix            # パッケージ一覧
    zsh.nix                 # シェル設定
    git.nix                 # Git 設定
config/
  nvim/                     # Neovim 設定 (LazyVim)
  cmux/                     # cmux (Ghostty) 設定
apply.sh                   # 日常の Nix 設定反映スクリプト
setup.sh                   # ブートストラップスクリプト
```

## 設定変更の適用

日常の Nix 設定変更は `apply.sh` で反映する:

```bash
./apply.sh
```

macOS ではホスト名に対応した純粋な flake target を優先し、未登録ホストでは `#auto --impure` にフォールバックする。
前回適用後に `flake.nix` / `flake.lock` / `nix/` 配下が変わっていない場合は rebuild をスキップする。強制適用する場合:

```bash
./apply.sh --force
```

初回セットアップや Nix 外ツールも含めて再確認したい場合は `./setup.sh` を使う。
