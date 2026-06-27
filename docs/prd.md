# PRD: 寄せ書き (yosegaki) V1 / V2 / V3

> 作成: 2026-06-27  
> ベース: HANDOFF.md / REFERENCE.md / V3_PLAN.md / ADR-001 / ADR-002

---

## 1. Product Overview

**寄せ書き**: 24スロットの色紙にメッセージを円弧状に配置するデジタル色紙アプリ。
協調書き込み（同時編集＋ロック）を特徴とし、Void デザインパターン（空→回転→書込→配置）をコア体験とする。

### ユーザー体験の流れ

1. ユーザーがボードを作成 or 既存ボードに参加
2. 空きスロットをタップ → 色紙が回転
3. メッセージを入力 → Enter で確定
4. 文字が円弧状に配置され、次のユーザーが別スロットに書き込める
5. 全24スロットが埋まれば完成

---

## 2. V1 — yosegaki-poc ✅ デプロイ済み

| 項目 | 内容 |
|------|------|
| リポジトリ | `bonsai/yosegaki-poc` |
| スタック | Vercel + Supabase (Vanilla JS) |
| URL | `https://yosegaki-poc.vercel.app` |
| 状態 | ✅ **デプロイ済み（2026-06-27）** |
| 位置づけ | 最小POC。Supabase で寄せ書きの基本フローを検証 |
| 今後の扱い | 参照用。V2/V3 の知見供給源。積極開発はしない |

### 2.1 機能一覧

| 機能 | 状態 | 備考 |
|------|------|------|
| 24スロット円弧配置 | ✅ | Canvas + SVG |
| タップ→回転→書き込み | ✅ | 基本フロー |
| Supabase 永続化 | ✅ | boards / messages テーブル |
| ボード作成/参加UI | ✅ | ID指定 or 新規作成 |
| URL共有 | ✅ | クエリパラメータ経由 |
| メッセージ削除 | ✅ | クリックで削除 |
| ランダムフォント/カラー | ✅ | 5フォント・7色・5サイズ |
| 和紙背景 | ✅ | Canvas 2D テクスチャ |

### 2.2 制限事項

| 項目 | 理由 |
|------|------|
| リアルタイム同期なし | POCのため。読み込み時のみデータ取得 |
| ロック機構なし | 同時編集の競合は未考慮 |
| 認証なし | 管理パスワードのみ |
| Supabase未設定時はローカル専用 | config.js が空の場合 localStorage もなし |

---

## 3. V2 — yosegaki-web ✅ LIVE

| 項目 | 内容 |
|------|------|
| リポジトリ | `bonsai/yosegaki-web` |
| スタック | Firebase Hosting + Firestore + Vanilla JS |
| URL | `https://yose-gaki.web.app` |
| 状態 | ✅ **LIVE / アクティブ開発中** |
| コード規模 | yosegaki.js 738行 / yosegaki.html 63行 / yosegaki.css |

### 3.1 機能一覧（実装済み）

| 機能 | 状態 | 詳細 |
|------|------|------|
| 24スロット円弧配置 | ✅ | 楕円軌道上に均等配置 |
| Void ステートマシン | ✅ | VOID → ROTATING(0.72s) → WRITING → PLACED |
| Firestore 永続化 | ✅ | boards / messages コレクション |
| リアルタイム同期 (onSnapshot) | ✅ | 他ユーザーの書き込み即時反映 |
| スロットロック | ✅ | activeLocks Map + Firestore 競合回避 |
| ボード作成UI | ✅ | タイトル + 管理パスワード |
| ボードURL共有 | ✅ | URL生成 + copy |
| 削除機能（長押し/ホバー） | ✅ | 削除ボタン表示 + Firestore 削除 |
| テストデータ追加 | ✅ | サンプルメッセージ一括挿入 |
| 統計表示 (ALL/NOW/NEW) | ✅ | 埋まり数・アクティブロック・新着数 |
| 和紙キャンバス背景 | ✅ | Canvas 2D で和紙テクスチャ描画 |
| スロット装飾SVG | ✅ | 枠線・選択ハイライト・エッジ装飾 |
| フォント選択 (5種) | ✅ | Zen Antique / Kaisei Decol / 他 |
| カラーパレット (7色) | ✅ | 赤橙緑青紫桃黒 |
| フォントサイズ調整 | ✅ | 14-22px 5段階 |
| 触覚フィードバック | ✅ | 回転成功/書込確定/キャンセル/エラー |
| トースト通知 | ✅ | 各種イベント通知 |
| ピンチズーム | ✅ | 2本指デバッグ情報表示 |
| ダミーメッセージ | ✅ | お疲れ様でした!! 虹色表示 |

### 3.2 未解決ISSUE

| # | 課題 | 優先度 |
|---|------|--------|
| #34 | Firestore export workflow + docs (review指摘未対応) | P0 |
| #33 | SUPABASE_URL / ANON_KEY 未設定 (CI) | P0 |
| #30 | Smoke test checklist (手動テスト未完了) | P0 |
| #27 | iOS Safari hiddenInput.focus() 確認 | P0 |
| — | config.js 直書きAPIKey → secret scan 失敗 | P0 |
| — | Firestore rules full open → 本番用に制限 | P1 |
| — | Firebase billing Blaze未設定 | P0 |

### 3.3 CI/CD

- GitHub Actions: Firebase Hosting deploy (main/master push時)
- PR #34 CI: ❌ Lint / Validate CF Worker / Secret scan が失敗中

### 3.4 技術的課題

- config.js に本番APIKeyが生書き → secret scan 検知
- main / master ブランチ混在
- CIにCF Worker validateが混入 (V2なのにCF不要)
- db.settings({ merge: true }) がプラグイン未使用の互換コード

---

## 4. V3 — shikishi 🟡 設計済み

| 項目 | 内容 |
|------|------|
| リポジトリ | `bonsai/shikishi` |
| スタック | Nuxt 3 + Vue 3 + Vite + D1 + CF Pages SSR |
| デプロイ先 | Cloudflare Pages SSR |
| URL | `shikishi.onsen-bonsai.workers.dev` (予定) |
| 状態 | **scaffold + コンポーネント実装済み** |
| 位置づけ | **有料サイト** — V2の知見を活かしたフルリプレイス |

### 4.1 設計済みコンポーネント

| ファイル | 役割 | 状態 |
|---------|------|------|
| `pages/index.vue` | トップページ (Void state 表示) | ✅ scaffold |
| `pages/board/[id].vue` | ボード画面 | ✅ scaffold |
| `components/WashiPaper.vue` | 和紙キャンバス背景 | ✅ 実装 |
| `components/OvalFrame.vue` | 楕円フレーム (SVG) | ✅ 実装 |
| `components/MessageLayer.vue` | メッセージレイヤー | ✅ 実装 |
| `components/WriteZone.vue` | 書き込みゾーン | ✅ 実装 |
| `composables/useBoard.ts` | ボードデータ入出力 | ✅ 実装 (Supabase依存) |
| `server/api/board/*.ts` | Board CRUD API | ✅ 実装 (Supabase依存) |
| `server/api/message/*.ts` | Message CRUD API | ✅ 実装 (Supabase依存) |
| `server/api/lock/*.ts` | Lock API | ✅ 実装 (Supabase依存) |
| `utils/oval.ts` | 楕円座標計算 | ✅ |
| `utils/color.ts` | カラーパレット | ✅ |
| `types/board.ts` | 型定義 | ✅ |

### 4.2 D1 移行方針 (ADR-002)

| 置き換え対象 | 移行先 |
|-------------|--------|
| `server/utils/supabase.ts` | `server/utils/d1.ts` (D1 binding wrapper) |
| supabase-js CRUD | D1PrepareStatement + SQL |
| Supabase Realtime | Polling (3-5s) |
| runtimeConfig supabase | wrangler.toml → env.DB |

### 4.3 Void デザインパターン

```
State Machine: VOID → tap → ROTATING(0.72s) → WRITING → Enter → PLACED
                                                          Esc → VOID
```

V2 のステートマシンを Vue composable として再実装。Vue `<Transition>` ベース。

### 4.4 有料サイト化の未定要素

| 要素 | 現状 | 課題 |
|------|------|------|
| 認証 | 未実装 | CF Access? 独自JWT? |
| 課金 | 未実装 | Stripe? |
| レート制限 | 未実装 | DO + KV |
| 管理画面 | 未実装 | studio/ 設計のみ |
| カスタムドメイン | 未定 | shikishi.example.com? |

---

## 5. バージョン比較

| 観点 | V1 (poc) | V2 (web) | V3 (shikishi) |
|------|---------|---------|---------------|
| フレームワーク | — (Vanilla) | — (Vanilla) | Nuxt 3 + Vue 3 |
| 言語 | JS | JS | TypeScript |
| DB | Supabase | Firestore | D1 (SQLite) |
| リアルタイム | なし | Firestore onSnapshot | Polling / DO |
| 認証 | なし | なし | 要実装 |
| ホスティング | Vercel | Firebase Hosting | CF Pages SSR |
| CI/CD | Vercel自動 | GitHub Actions | GitHub Actions |
| UI品質 | 最小 | 実用レベル | 本番品質 |
| コード行数 | ~400 | ~800 | ~2000 (見込) |
| 料金 | 無料 | 無料 | 有料 |

---

## 6. 開発ロードマップ

```
Phase A: V2 安定化（今週）
  - PR #34 CI通過 (setup-node / secret scan 修正)
  - config.js の secrets 化
  - Firestore rules 制限
  - master ブランチ削除 / main 一本化

Phase B: V3 D1 移行（来週）
  - wrangler.toml + D1 binding
  - server/utils/supabase.ts → d1.ts
  - API routes SQL化
  - composables/useBoard.ts Polling化
  - ローカル dev 確認

Phase C: V3 デプロイ（V2安定後）
  - wrangler pages deploy
  - GitHub Actions deploy workflow
  - Void デザイン最終調整

Phase D: V3 有料化（将来）
  - 認証追加
  - 決済連携
  - 管理画面
  - カスタムドメイン
```

## 7. リポジトリ一覧

| リポジトリ | V | 可視性 | 状態 |
|-----------|---|--------|------|
| `bonsai/yosegaki-poc` | V1 | Private | ✅ デプロイ済み |
| `bonsai/yosegaki-web` | V2 | Private | ✅ LIVE |
| `bonsai/shikishi` | V3 | Private | 🟡 設計済み |
| `bonsai/yosegaki-v1` | — | Private | 🗑 命名混乱により archive 予定 |
| `bonsai/yosegaki-v2` | — | Private | 🗑 命名混乱により archive 予定 |

## 参照

- ADR-001: V1/V2/V3 分離戦略
- ADR-002: shikishi V3 — Supabase → D1 移行計画
- V3_PLAN.md: Nuxt 3 + Supabase 詳細設計
- HANDOFF.md: プロジェクト一時停止時の引継ぎ文書
- REFERENCE.md: 全環境・URL・Firebase設定の一覧
