---
name: claude-code
description: >
  GitHub Copilot CLI から Claude Code CLI (`claude`) を非対話モード (-p/--print) で実行し、
  タスクの委譲・セカンドオピニオン・レビューを行う時に使う。
  「Claude Codeで実行して」「Claude Codeに投げて」「claude -pで」「Claude Codeにやらせて」
  「Claude Codeの意見も聞きたい」などのリクエスト時に使用する。
  Claude Code 自体のアップデートは claude-update スキルを使う。
---

# Claude Code 実行 (Copilot CLI から)

Copilot CLI のセッション内から `claude` CLI をヘッドレス実行し、タスクの委譲・レビュー・
セカンドオピニオン取得を行うためのガイド。`claude` は `~/dotfiles/bun/node_modules/.bin`
経由で PATH に載っているため、追加セットアップなしでそのまま呼び出せる。

## 前提

- `claude --version` で疎通確認できる（bun 管理、`claude-update` スキルで更新）。
- 対話UIは使わず、必ず `-p`/`--print`（非対話モード）で実行する。
- 実行はサンドボックスされていない環境で行われる可能性があるため、権限モードとツール範囲を
  タスクに応じて必ず絞り込む（後述）。

## 基本コマンド

```bash
claude -p "<prompt>" \
  --output-format json \
  --permission-mode <mode> \
  --add-dir <target-repo-path>
```

- 実行ディレクトリは `cd <target-repo-path> && claude -p ...` でも `--add-dir` でもよいが、
  対象リポジトリを明示すること。
- 結果だけでなくコストやセッションIDも確認したい場合は `--output-format json` を使う
  （`result` / `total_cost_usd` / `session_id` 等を含む JSON が1発返る）。
- 単純にテキストで結果だけ欲しい場合は `--output-format text`（デフォルト）でよい。

## 権限モード（`--permission-mode`）の選び方

| モード | 用途 | 備考 |
|---|---|---|
| `plan` | 調査・設計案のみ欲しい時 | ファイル変更・コマンド実行をさせない読み取り専用の相談に最適 |
| `default` | 通常の対話同等の確認を求める | 非対話ではプロンプトが出せず止まることがあるため headless では基本非推奨 |
| `acceptEdits` | ファイル編集は許可するが危険操作は都度確認したい | 軽い編集委譲の既定値として妥当 |
| `dontAsk` / `auto` | ツール利用の確認を極力省略したい | 影響範囲が読めるタスクに限定して使う |
| `bypassPermissions` | 全権限チェックをスキップ | **原則使わない**。使うとしてもサンドボックス済み・使い捨て環境限定 |

迷ったら `plan`（調査のみ）→ 内容を確認 → 必要なら `acceptEdits` で本実行、の2段階にする。

## 用途別パターン

**1. 読み取り専用の調査・セカンドオピニオン**
```bash
claude -p "このリポジトリの認証まわりの実装を調査して、問題点を指摘して" \
  --permission-mode plan \
  --add-dir ~/code/some-repo
```

**2. 編集タスクの委譲（スコープを絞る）**
```bash
claude -p "src/foo.ts のバグを修正して" \
  --permission-mode acceptEdits \
  --allowed-tools "Read,Edit,Bash(git diff)" \
  --add-dir ~/code/some-repo \
  --output-format json
```

**3. コストに上限を付けて実行**
```bash
claude -p "<prompt>" --permission-mode acceptEdits --max-budget-usd 1.0
```

**4. 既存セッションの継続 / 再開**
```bash
claude -p "<追加の指示>" --resume <session-id>
# または直近セッションの続き
claude -p "<追加の指示>" --continue
```

## 実行後にやること

1. `--output-format json` の場合、`result` を要約してユーザーに提示する。
2. Claude Code がファイルを編集した場合は `git status` / `git diff` で変更内容を確認し、
   意図しない変更が含まれていないか確認してからユーザーに報告する。
3. コストを気にする文脈では `total_cost_usd` を併せて報告する。

## 注意事項

- 非サンドボックス環境である前提を忘れず、`bypassPermissions` やシークレットを含む
  プロンプト・出力の外部送信は行わない。
- 大きめのタスクは `--allowed-tools` / `--disallowed-tools` で許可ツールを明示し、
  想定外の Bash 実行や外部通信を防ぐ。
- Copilot CLI 自身のサブエージェント（task ツール）で十分な場合はそちらを優先し、
  「Claude Code 固有の挙動を明示的に使いたい」という要求がある時にこのスキルを使う。
