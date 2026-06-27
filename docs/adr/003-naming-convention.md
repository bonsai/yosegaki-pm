# ADR-003: プロジェクト管理ファイル命名規則

## ステータス

採用 (2026-06-27)

## コンテキスト

yosegaki プロジェクトでは複数の管理ファイルが混在していた:
- `yosegaki.db` — GitHub Issues の統合管理
- `yosegaki.kanban.db` — カンバンボード
- `yosegaki-web/docs/ADR-001.md` — アーキテクチャ決定記録
- `yosegaki-web/docs/ONTOLOGY.md` — ドメインオントロジー

プロジェクトが V1/V2/V3 に分散するにつれ、「どのファイルがどのプロジェクトに属するか」「どの種別か」が曖昧になった。

## 決定

**type-first 命名** を採用する。

### DB ファイル

```
{type}.{project}.db
```

| 実ファイル | 意味 |
|---|---|
| `issues.yosegaki.db` | GitHub Issues 統合管理 |
| `kanban.yosegaki.db` | カンバンボード |

### ADR ファイル

```
docs/adr/{number}-{kebab-topic}.md
```

| 実ファイル | 意味 |
|---|---|
| `docs/adr/001-version-separation.md` | バージョン分離方針 |
| `docs/adr/002-d1-migration.md` | D1 移行計画 (TODO) |
| `docs/adr/003-naming-convention.md` | 本ADR |

### ドキュメント

```
docs/{type}.md
```

| 実ファイル | 意味 |
|---|---|
| `docs/ontology.md` | ドメインオントロジー |
| `docs/prd.md` | プロダクト要求定義 |
| `docs/handoff.md` | 引き継ぎ文書 |
| `docs/reference.md` | 技術リファレンス |

## 根拠

1. **グルーピング**: `ls *.yosegaki.db` / `ls docs/adr/*.md` で種別単位の一覧が容易
2. **拡張性**: 新プロジェクトが増えても `{type}.{project}.db` パターンで統一
3. **ADR 番号順**: 時系列で決定履歴を追跡可能

## 影響

- 既存の `yosegaki.db` を `issues.yosegaki.db` にリネーム済み
- `yosegaki.kanban.db` を `kanban.yosegaki.db` にリネーム済み
- 参照スクリプト (`sync_issues_to_db.py`) のパス更新済み
- 共有ドキュメントは `bonsai/yosegaki-pm` リポジトリに集約 (ADR-004)
