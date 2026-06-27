# yosegaki-pm — プロジェクト管理ハブ

yosegaki 寄せ書き色紙アプリケーションの統合プロジェクト管理。

## 構成

```
docs/
├── adr/             アーキテクチャ決定記録
│   ├── 001-version-separation.md
│   ├── 003-naming-convention.md
│   └── 004-yosegaki-pm-hub.md
├── ontology.md      ドメインモデル
├── prd.md           プロダクト要求定義
├── handoff.md       引き継ぎ文書
├── reference.md     技術リファレンス
└── v3-plan.md       V3 (shikishi) 移行計画
db/
├── schema-issues.sql
└── schema-kanban.sql
```

## 関連リポジトリ

| バージョン | リポジトリ | デプロイ先 | 状態 |
|---|---|---|---|
| V1 | bonsai/yosegaki-poc | Vercel | POC (localStorage) |
| V2 | bonsai/yosegaki-web | Firebase Hosting | LIVE |
| V3 | bonsai/shikishi | Cloudflare Pages | 設計段階 |

## ローカル管理DB

- `issues.yosegaki.db` — V1/V2/V3 Issue 横断管理 (MEGA直下)
- `kanban.yosegaki.db` — カンバンボード (MEGA直下)
