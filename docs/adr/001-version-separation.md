# ADR-001: 寄せ書き V1/V2/V3 分離戦略

## ステータス

**採択: 2026-06-27** — バージョン別リポジトリ分離。
2026-06-27 更新: V1/V2/V3 の定義を正しく再構成。

## 背景

寄せ書きアプリは技術スタックの変遷に伴い3バージョンが存在する。
当初 `bonsai/yosegaki-web` に全バージョンを混在させたが、LLMエージェント運用におけるブランチ混乱・同名ファイル混同・CI煩雑化のリスクが顕在化した。

## 最終版 バージョン定義

| V | リポジトリ | スタック | デプロイ先 | URL | 状態 |
|---|-----------|---------|-----------|-----|------|
| **V1** | `bonsai/yosegaki-poc` | Vercel + Supabase | Vercel | `yosegaki-web.vercel.app` | ❌ 停止中 (404) |
| **V2** | `bonsai/yosegaki-web` | Firebase + Vanilla JS + Firestore + デバッグBBS | Firebase Hosting | `yose-gaki.web.app` | ✅ **LIVE / 開発中** |
| **V3** | `bonsai/shikishi` | Nuxt 3 + Vue 3 + Supabase + CF Pages SSR | Cloudflare Pages | `shikishi.onsen-bonsai.workers.dev` (予定) | 🟡 スキャフォールド済み |

### 補足: 既存リポジトリの整理

| リポジトリ | 扱い |
|-----------|------|
| `bonsai/yosegaki-v1` | 命名混乱により削除 or archive。V1 の正体は `yosegaki-poc` |
| `bonsai/yosegaki-v2` | 命名混乱により削除 or archive。V2 の正体は `yosegaki-web` |
| `bonsai/yosegaki-web` | **現行の開発リポジトリとして継続**。V2 の本拠。PR #34 もここ |

## LLMエージェント運用におけるリスク分析

### ブランチ3本での同時運用（単一リポジトリ x 3ブランチ）

| リスク | severity | 対策 |
|--------|----------|------|
| **同名ファイル混同**: `package.json` / `tsconfig.json` / `deploy.yml` が全ブランチに存在 | HIGH | 分離repoなら絶対起きない |
| **LLMのブランチ認識漏れ**: 作業ディレクトリ固定のまま git checkout でコンテキストが入れ替わる | HIGH | AGENTS.md に「今のブランチ: V2」を常時表示 |
| **PRの所属不明**: PR #34 が V1 向けか V2 向けか一目でわからない | MEDIUM | ラベル/タイトル prefix で明確化 |
| **CIトリガー誤爆**: V1 の変更で V2/Shikishi の CI が動く | MEDIUM | path filter で軽減可能だが完全には防げない |

### 分離リポジトリのメリット（LLM観点）

1. **作業ディレクトリ = 所属**: `C:\...\yosegaki-web\` にいれば V2、`C:\...\shikishi\` にいれば V3。LLMがパスを見て即座に判断できる
2. **同名ファイルゼロ**: 全く同じファイル名が異なる内容で存在することがない
3. **CI単純**: 各repoが自分自身のデプロイだけ考えればよい
4. **認証情報が混入しない**: repoごとに .env / シークレットが独立

## 運用ルール（意識的monorepo）

物理的には分離していても、論理的にはmonorepoとして統制する:

1. **ISSUE管理**: 全repoに共通ラベル V1 V2 V3 を付与。ISSUE番号には V2-#34 のように repo prefix を付ける
2. **AGENTS.md**: 全repoの一覧と関係性を各repoの AGENTS.md に記載
3. **横断操作**: gh repo list bonsai + gh issue list で全repoを横断
4. **週次同期**: 各repoの進捗を一箇所（例: yosegaki-web の ISSUE）に集約

## 当面の進め方（優先順位）

1. **V2 (yosegaki-web) を安定稼働** → PR #34 を通す（Firestore export / Firestore rules 修正）
2. **V2 の config.js を secret 化** → secret scan 通過
3. **V3 (shikishi) は V2 安定後に着手** → 有料サイト化はその後
4. **V1 (yosegaki-poc) は現状維持（再稼働予定なし）**

## 参照

- HANDOFF.md: プロジェクト一時停止時の引継ぎ文書
- REFERENCE.md: 全環境・URL・Firebase設定の一覧
- V3_PLAN.md: Nuxt 3 + Supabase 詳細設計（shikishi 用）
