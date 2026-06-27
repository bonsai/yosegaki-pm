# ADR-004: yosegaki-pm プロジェクト管理ハブ

## ステータス

採用 (2026-06-27)

## コンテキスト

これまで以下が分散していた:
- オントロジー・ADR・PRD → `bonsai/yosegaki-web/docs/` (V2 リポジトリ)
- Issues 統合管理 → `issues.yosegaki.db` (ローカル)
- カンバン → `kanban.yosegaki.db` (ローカル)
- 各バージョンの Issue → 各リポジトリ (yosegaki-poc / yosegaki-web / shikishi)

V2 リポジトリに全管理文書が置かれていたため、V1/V3 のコンテキストを参照する際に混乱を招いていた。

## 決定

**`bonsai/yosegaki-pm` をプロジェクト管理ハブとする。**

### 責務

| 領域 | 配置 |
|---|---|
| ドメインオントロジー | `docs/ontology.md` |
| アーキテクチャ決定記録 (ADR) | `docs/adr/{number}-{topic}.md` |
| プロダクト要求定義 (PRD) | `docs/prd.md` |
| 引き継ぎ文書 | `docs/handoff.md` |
| 技術リファレンス | `docs/reference.md` |
| 移行計画 | `docs/v3-plan.md` |
| DB スキーマ定義 | `db/schema-issues.sql`, `db/schema-kanban.sql` |
| エージェント管理定義 | `AGENTS.md` (リポジトリルート) |

### 非責務 (各バージョンリポジトリに残るもの)

- 実装コード
- バージョン固有の CI/CD 設定
- デプロイ設定 (Firebase, Vercel, Cloudflare)

## 根拠

1. **単一参照点**: 全リポジトリ横断の設計情報が一箇所に集約される
2. **LLM 運用効率**: エージェントは `yosegaki-pm` の docs/ を読むだけで全容を把握可能
3. **バージョン中立**: V1/V2/V3 いずれにも依存しない独立リポジトリ
4. **クロスリポ Issues 管理**: `issues.yosegaki.db` で V1/V2/V3 の Issue を横断管理

## 影響

- `bonsai/yosegaki-web` の docs/ は参照コピーとして維持 (削除しない)
- 新規 ADR はすべて `yosegaki-pm/docs/adr/` に作成
- ローカル DB (`issues.yosegaki.db`, `kanban.yosegaki.db`) は `MEGA/` 直下に維持
