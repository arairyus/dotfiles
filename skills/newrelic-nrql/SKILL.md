---
name: newrelic-nrql
description: >
  New Relic MCP ツール (execute_nrql_query, natural_language_to_nrql_query,
  analyze_transactions, analyze_entity_logs, analyze_golden_metrics 等) を使った
  NRQL クエリ作成・障害調査の精度を上げるためのガイド。
  「New Relicで調べて」「エラー率を見て」「レイテンシが遅い」「ログを調査して」
  「golden signals」「NRQL書いて」「ダッシュボードのクエリを直して」など
  observability データの調査・分析を依頼されたときに使う。
  New Relic ダッシュボードの mutation (dashboardUpdate) 編集は newrelic-dashboard スキルを使う。
---

# New Relic NRQL / Observability スキル

New Relic MCP サーバーのツールを使って NRQL クエリの精度と調査効率を上げるためのガイド。
[newrelic-partners/newrelic-kiro-power](https://github.com/newrelic-partners/newrelic-kiro-power) の
steering ドキュメント（NRQL guide / query patterns / troubleshooting workflows）の知見を、
このCLI環境で実際に使える New Relic MCP ツール名にマッピングし直して再構成したもの。

---

## 0. コア原則

1. **狭い時間範囲から始める** — `SINCE 30 minutes ago` / `SINCE 1 hour ago` から開始し、必要な場合のみ `4 hours ago` → `24 hours ago` と広げる
2. **entity で必ず絞り込む** — `WHERE appName = 'X'` / `` WHERE `service.name` = 'X' `` / `WHERE entity.guid = '...'`
3. **LIMIT を必ず付ける** — 通常 `LIMIT 100`、詳細調査は `20-50`、網羅的収集は `500-1000`
4. **Golden Signals から着手** — Latency / Traffic / Errors / Saturation の順で健全性を俯瞰
5. **account を先に確定** — `list_available_new_relic_accounts` で対象アカウントIDを確認してからクエリを組み立てる

---

## 1. どのツールを使うか

生の NRQL を書く前に、目的に合った専用ツールがあるか確認する。専用ツールの方が集計・整形済みで精度が高い。

| 目的 | 優先ツール | 備考 |
|------|-----------|------|
| アカウント確認 | `list_available_new_relic_accounts` | 最初に実行してaccountIdを確定 |
| エンティティ特定 | `get_entity` / `search_entity_with_tag` / `list_related_entities` | appName/service.nameだけでなくGUIDでも引ける |
| 自然文からNRQL生成 | `natural_language_to_nrql_query` | クエリの叩き台。生成後は本ガイドの原則で検証・調整する |
| 任意のNRQL実行 | `execute_nrql_query` | 専用ツールがない場合の汎用手段 |
| Golden Signals一括 | `analyze_golden_metrics` | Latency/Traffic/Errors/Saturationを個別に書く前にまず試す |
| トランザクション分析 | `analyze_transactions` | 遅いエンドポイント・スループット調査 |
| ログ分析 | `analyze_entity_logs` / `list_recent_logs` | entity単位はanalyze_entity_logs、横断検索はlist_recent_logs |
| スレッド/GC分析 | `analyze_threads` / `list_garbage_collection_metrics` | JVM系のボトルネック調査 |
| Kafka分析 | `analyze_kafka_metrics` | Kafka consumer/producerのメトリクス |
| デプロイ影響分析 | `analyze_deployment_impact` / `list_change_events` | 直近デプロイと障害の相関確認は必須ステップ |
| インシデント/アラート | `list_recent_issues` / `search_incident` / `list_alert_conditions` / `list_alert_policies` | アラート起因の調査はここから開始 |
| リスク傾向 | `list_entity_performance_risk_groups` / `list_entity_error_groups` | 事後分析・優先度付けに使う |
| ダッシュボード参照 | `list_dashboards` / `get_dashboard` | 既存ダッシュボードのクエリを再利用できないか確認 |
| Synthetics | `list_synthetic_monitors` | 外形監視の状態確認 |
| レポート生成 | `generate_alert_insights_report` / `generate_user_impact_report` | 障害振り返り・影響範囲のサマリ作成 |
| 時刻変換 | `convert_time_period_to_epoch_ms` | 絶対時刻でのSINCE/UNTIL指定が必要な時 |

---

## 2. NRQL 構文リファレンス（要点）

```nrql
SELECT <attributes/functions>
FROM <event_type>
WHERE <conditions>
FACET <grouping>
SINCE <time_range>
LIMIT <count>
```

**主要 Event Type**

| Event Type | 用途 | 主要属性 |
|---|---|---|
| `Transaction` | APM トランザクション | appName, name, duration, error |
| `TransactionError` | アプリエラー | error.class, error.message, transactionName |
| `Span` | 分散トレースのスパン | traceId, duration.ms, service.name, category |
| `Log` | ログ | message, level, entity.guid, service.name |
| `Metric` | ディメンショナルメトリクス | metricName, entity.guid |
| `SystemSample` | ホストメトリクス | cpuPercent, memoryUsedPercent, hostname |
| `ProcessSample` | プロセスメトリクス | cpuPercent, memoryResidentSizeBytes |
| `NetworkSample` | ネットワークメトリクス | receiveBytesPerSecond, transmitBytesPerSecond |
| `Deployment` | デプロイイベント | appName, revision, user |

**よく使う関数**
```nrql
count(*), average(duration), sum(duration), min()/max()
percentile(duration, 50, 95, 99)
rate(count(*), 1 minute)
uniqueCount(userId), latest(attribute)
filter(count(*), WHERE error IS true)
percentage(count(*), WHERE error IS true)
derivative(average(duration), 1 minute)
histogram(duration, 100, 20)
```

**FACET**
```nrql
FACET appName, host LIMIT 20
FACET CASES (WHERE duration < 100 AS 'Fast', WHERE duration >= 1000 AS 'Slow')
FACET buckets(duration, 100, 20)
```

**時間範囲 / TIMESERIES**
```nrql
SINCE 30 minutes ago | SINCE 1 hour ago | SINCE 4 hours ago | SINCE 1 day ago
SINCE 2 hours ago UNTIL 1 hour ago
TIMESERIES AUTO | TIMESERIES 1 minute | TIMESERIES MAX (max 366 buckets)
```

**期間比較**
```nrql
SELECT percentile(duration, 95) FROM Transaction
WHERE appName = 'X' SINCE 1 hour ago COMPARE WITH 1 day ago
```

---

## 3. Golden Signals クエリパターン

**Latency**
```nrql
SELECT percentile(duration, 50, 95, 99) FROM Transaction WHERE appName = 'X' SINCE 1 hour ago
SELECT average(duration.ms) FROM Span WHERE category = 'datastore' AND `service.name` = 'X' FACET db.statement SINCE 1 hour ago LIMIT 20
```

**Traffic**
```nrql
SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = 'X' TIMESERIES AUTO SINCE 1 hour ago
```

**Errors**
```nrql
SELECT percentage(count(*), WHERE error IS true) as 'Error Rate %' FROM Transaction WHERE appName = 'X' SINCE 1 hour ago
SELECT count(*) FROM TransactionError WHERE appName = 'X' FACET error.class SINCE 1 hour ago LIMIT 20
```

**Saturation**
```nrql
SELECT average(cpuPercent), average(memoryUsedPercent) FROM SystemSample WHERE hostname LIKE 'prod-%' FACET hostname SINCE 1 hour ago
```

これらは `analyze_golden_metrics` / `analyze_transactions` で代替できないか先に確認する。

---

## 4. トラブルシュートの標準フロー

### 4-1. 本番エラー調査
1. `list_available_new_relic_accounts` → アカウント確定
2. `analyze_golden_metrics` または Error Rate クエリでエラー率確認
3. `TransactionError` を `FACET error.class, error.message` で分類
4. `analyze_entity_logs` で該当時間帯の ERROR ログ取得
5. `Span` を `WHERE error IS true` で関連トレース取得
6. `analyze_deployment_impact` / `list_change_events` で直近デプロイとの相関確認

### 4-2. パフォーマンス劣化調査
1. `COMPARE WITH 1 day ago` で現在と過去のレイテンシ比較
2. `analyze_transactions` で遅いエンドポイントを特定
3. `Span WHERE category = 'datastore'` で DB クエリ性能確認
4. `SystemSample` でインフラ (CPU/Memory) 確認
5. `Span WHERE category = 'http'` で外部サービス呼び出し確認

### 4-3. サービス依存関係調査
1. `Span FACET peer.service, category` でサービス間呼び出し一覧
2. `Span WHERE error IS true FACET service.name, peer.service` でエラー伝播確認
3. 外部依存は `http.url` / `http.status_code` で絞り込み

### 4-4. アラート調査
1. `list_recent_issues` / `search_incident` で対象インシデント特定
2. `list_alert_conditions` / `list_alert_policies` でアラート条件確認
3. 関連メトリクスを `TIMESERIES AUTO` で時系列確認、エラーと相関を取る
4. `generate_alert_insights_report` で振り返りレポート作成

---

## 5. アンチパターン（必ず避ける）

| ❌ Bad | ✅ Good |
|---|---|
| `SELECT * FROM Transaction WHERE appName = 'X'`（時間範囲なし） | 末尾に `SINCE 1 hour ago` を必ず付ける |
| `SELECT * FROM Log WHERE level = 'ERROR' SINCE 1 day ago`（LIMITなし） | `LIMIT 100` を付ける |
| `SELECT count(*) FROM Transaction SINCE 1 hour ago`（entity絞り込みなし） | `WHERE appName = 'X'` を付ける |
| `WHERE message LIKE '%error%'`（曖昧な部分一致） | `WHERE level = 'ERROR' AND message LIKE '%timeout%'` |
| `SELECT * FROM Transaction WHERE appName='X' SINCE 30 days ago`（長期間の生データ） | `FACET dateOf(timestamp)` で集計してから見る |
| `FACET traceId`（高cardinality） | `FACET name LIMIT 20` など低cardinalityな属性を使う |

---

## 6. 実行前チェックリスト

- [ ] account を確定したか (`list_available_new_relic_accounts`)
- [ ] 専用ツール (`analyze_*`) で代替できないか確認したか
- [ ] `SINCE` を短い範囲から設定したか
- [ ] `appName` / `service.name` / `entity.guid` で絞り込んだか
- [ ] `LIMIT` を付けたか
- [ ] 高cardinalityな属性を `FACET` していないか
- [ ] 直近デプロイとの相関を確認したか（障害調査時）
