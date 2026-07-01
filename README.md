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

## セキュリティ設定

Takumi Guard (npm ecosystem) を有効化済み。Home Manager で以下を配布する:

- `~/.npmrc` (`registry=https://npm.flatt.tech`)
- `~/.config/pnpm/rc` (`registry=https://npm.flatt.tech`)
- `~/.yarnrc.yml` (`npmRegistryServer: "https://npm.flatt.tech"`)
- `~/.bunfig.toml` (`[install] registry = "https://npm.flatt.tech"`)

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
skills/                     # Claude / Codex / Copilot CLI 共通スキル (SKILL.md)
scripts/
  skills-sync.sh            # skills/ を各ツールへ symlink 配置
  skills-promote.sh         # ローカルで作られたスキルを dotfiles に昇格
apply.sh                   # 日常の Nix 設定反映スクリプト
setup.sh                   # ブートストラップスクリプト
```

## スキル管理 (Claude / Codex / Copilot CLI)

`skills/<name>/SKILL.md` に置いたスキルは `scripts/skills-sync.sh` で各ツールの
スキルディレクトリへ **スキル単位のシンボリックリンク** として配置される。

- `~/.claude/skills/<name>`
- `~/.codex/skills/<name>`
- `~/.copilot/skills/<name>`

ディレクトリ単位ではなくスキルごとに symlink するため、業務固有の情報を含む
スキルは各ツールのスキルディレクトリに実ディレクトリとして置いたままにしておけば、
このリポジトリに取り込まれず(sync 時は自動でスキップされる)、他の dotfiles
管理スキルとも共存できる。`setup.sh` 実行時に自動で同期されるほか、スキル追加後は
以下で即時反映できる:

```bash
./scripts/skills-sync.sh
```

Claude/Codex/Copilot 上で作業中に作られたローカルスキルを dotfiles 管理に切り替えたい場合は
`skills-promote.sh` で該当ツールのスキルディレクトリから `skills/` へ移動し、
3ツール分の symlink を張り直す:

```bash
./scripts/skills-promote.sh <skill-name>
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
