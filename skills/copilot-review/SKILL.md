---
name: copilot-review
description: >
  Claude Code (や Codex) から GitHub Copilot CLI (`copilot`) を非対話モード (-p/--prompt) で
  呼び出し、GPT-5.5 モデルにコードレビュー・セキュリティレビューをさせる時に使う。
  「Copilot CLIでレビューして」「GPT-5.5でレビューして」「copilotに投げて」
  「セカンドオピニオン欲しい」「他のモデルにもレビューさせて」などのリクエスト時に使用する。
  Copilot CLI 自体のアップデートは対象外。Claude Code 側を呼ぶ場合は claude-code スキルを使う。
---

# Copilot CLI (GPT-5.5) レビュー実行 (Claude Code / Codex から)

Claude Code や Codex のセッション内から `copilot` CLI をヘッドレス実行し、
GPT-5.5 モデルによるコードレビュー／セキュリティレビューをセカンドオピニオンとして
取得するためのガイド。`copilot` は `~/.local/bin/copilot` で PATH に載っている。

## 前提

- `copilot --version` で疎通確認できる。
- 非対話モードは `-p/--prompt`。**非対話モードでは `--allow-all-tools` が必須**（付けないと
  ツール実行の承認待ちで止まる）。
- モデルは `--model gpt-5.5` を明示する（省略すると別モデルや自動選択になる）。
- **`--allow-all-tools` は shell 実行も自動承認する点に注意**。`/review` は差分取得や
  ファイル探索のために `git`/`ls`/`find`/`cat` 等を内部で使うため、shell を狭く絞ると
  権限不足で途中停止する（動作確認済み：`shell(git:*)` のみ許可すると `ls`/`find` で
  `Permission denied` になり操作が止まった）。そのため `--deny-tool write` を足しても
  「完全な読み取り専用」は保証されない（shellツール自体は別枠で許可されたまま）。
  信頼できるリポジトリ・差分に対してのみ使うこと。より厳格な隔離が必要な場合は
  使い捨てのworktree/クローンで実行する。

## 基本コマンド（差分レビュー）

```bash
copilot -p "/review" \
  --model gpt-5.5 \
  --allow-all-tools \
  --deny-tool write \
  -s \
  --output-format text \
  -C <target-repo-path>
```

- `/review` は Copilot CLI 組み込みのコードレビューエージェント。ステージ済み・未ステージ・
  ブランチ差分を自動判定し、バグや重大な問題だけを高いS/N比で指摘する（スタイル指摘はしない）。
- `-C <target-repo-path>` でレビュー対象リポジトリを明示する（`cd` してから実行してもよい）。
- `-s`（silent）で統計情報を省き、レビュー本文だけを出力させる。
- 動作確認済み: `copilot -p "/review" --model gpt-5.5 -s --allow-all-tools` で差分ゼロ時は
  「レビュー対象の差分はありませんでした」、差分ありなら指摘事項が返る。

## 用途別パターン

**1. セキュリティ観点のレビュー**
```bash
copilot -p "/security-review" \
  --model gpt-5.5 \
  --allow-all-tools --deny-tool write \
  -s -C <target-repo-path>
```

**2. 特定PRのレビュー**
```bash
copilot -p "PR #123 をレビューして" \
  --model gpt-5.5 \
  --allow-all-tools --deny-tool write \
  -s -C <target-repo-path>
```

**3. JSON で結果を受け取り、他ツールでパースしたい場合**
```bash
copilot -p "/review" --model gpt-5.5 --allow-all-tools --deny-tool write \
  --output-format json -C <target-repo-path>
```
JSONL（1行1オブジェクト）で返る。最終的なエージェント応答を抽出して要約する。

**4. 自由記述のレビュー依頼（/review でカバーしにくい観点）**
```bash
copilot -p "src/foo.ts の並行処理まわりにレースコンディションがないかレビューして" \
  --model gpt-5.5 --allow-all-tools --deny-tool write \
  -s -C <target-repo-path>
```

## 実行後にやること

1. 返ってきた指摘事項を要約し、呼び出し元（ユーザー）に日本語で提示する。
2. 自分（Claude Code / Codex）の変更に対する指摘であれば、指摘の妥当性を検証してから
   修正するか判断する（GPT-5.5の指摘を無条件に正としない）。
3. `--output-format json` を使った場合は、statsやコストに関する行が混ざるので、最終応答の
   本文だけを抽出してから要約する。

## 注意事項

- 非サンドボックス環境である前提を忘れず、`--allow-all-paths` や `--allow-all-urls`
  （`--allow-all`/`--yolo`）は原則使わない。
- `--allow-all-tools` は shell 実行も自動承認するため、`--deny-tool write` を足しても
  「完全な読み取り専用」にはならない（shellでのファイル変更・削除・外部送信は理論上可能）。
  信頼できるリポジトリ・差分にのみ使い、機密情報を含む可能性がある未知の差分レビューは
  隔離環境（使い捨てworktree等）で行う。
- 大きすぎる差分は要約されて精度が落ちることがあるため、必要なら対象ファイル・ディレクトリを
  絞ったプロンプトにする。
- Claude Code 自身のsubagent（rubber-duck / code-review 等）で十分な場合はそちらを優先し、
  「別モデル(GPT-5.5)の視点を明示的に得たい」という要求がある時にこのスキルを使う。
