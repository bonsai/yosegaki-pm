# V3 移行計画 — Vue + Nuxt + Vite + Supabase

## Stack

```
Layer              Technology
──────────────────────────────────────────────
Framework          Nuxt 3 (Vue 3)
Build              Vite
Styling            Tailwind CSS / UnoCSS
Database           Supabase (Postgres + Realtime)
Auth               Supabase Auth (匿名 + OAuth)
Hosting            Cloudflare Pages (SSRモード)
Or                 Firebase Hosting + Pages Functions
```

### なぜこのスタックか

| 技術 | 選定理由 |
|------|---------|
| **Nuxt 3** | SSR/SSG/SPA を1つのフレームワークで選択可能。Vue 3 の Composition API + TypeScript 標準。ファイルベースルーティング。サーバールート（Nitáo）で API エンドポイントも内蔵可 |
| **Vite** | Nuxt 3 のデフォルトビルダー。HMR 高速。ESM ネイティブ |
| **Supabase** | Postgres + 自動 REST API + Realtime + Auth がバンドル。Firestore より複雑なクエリが可能。Managed で運用コストゼロ |
| **Cloudflare Pages** | Nuxt 3 SSR を Edge で実行可能。Firebase Hosting よりレイテンシ低い。無料枠十分 |

### Void デザインパターン

「寄せ書き」の本質 = **空白（void）に文字が現れる体験** を設計の中心に据える。

- 初期状態: 真っ白な色紙（void）だけが表示される
- タップ → 回転 → 文字入力 → 配置 → void が埋まる
- 24スロットすべて埋まったときの達成感 = void の完全な充足
- アニメーション・遷移は「無から有が現れる」を一貫して表現

---

## ディレクトリ構造

```
packages/
  app/                     ← Nuxt 3 frontend
    app.vue
    pages/
      index.vue            ← トップページ（新規作成 or board ID 入力）
      board/[id].vue       ← ボード画面（現行 yosegaki.html）
    components/
      WashiPaper.vue       ← 和紙背景（Canvas）
      OvalFrame.vue        ← 楕円フレーム（SVG）
      MessageSlot.vue      ← 1スロットの文字配置
      WriteZone.vue        ← 書き込みエリア
      BoardPanel.vue        ← ボード作成/設定パネル
      ToastHint.vue        ← ヒント/トースト
    composables/
      useBoard.ts          ← ボードデータ取得・状態管理
      useRealtime.ts       ← Supabase Realtime 購読
      useLock.ts           ← 排他ロック
      useRotation.ts       ← 回転アニメーション制御
      useHaptic.ts         ← バイブレーションフィードバック
    server/
      api/
        board/
          index.get.ts     ← GET /api/board/:id
          index.post.ts    ← POST /api/board
        message/
          index.get.ts     ← GET /api/message?board_id=
          index.post.ts    ← POST /api/message
          [id].delete.ts   ← DELETE /api/message/:id
        lock/
          index.post.ts    ← POST /api/lock (acquire)
          index.delete.ts  ← DELETE /api/lock (release)
    utils/
      oval.ts              ← 楕円座標計算
      wobble.ts            ← 手書き風歪み関数
      color.ts             ← カラーパレット
      font.ts              ← フォントリスト
    assets/
      washi.ts             ← 和紙テクスチャ生成
    types/
      board.ts
      message.ts
    nuxt.config.ts
  studio/                  ← 管理画面（オプション）
    app.vue
    pages/
      board/[id]/admin.vue ← パスワード保護管理画面
```

---

## Page Design

### `/` — トップページ（Void の提示）

```
[ 寄 せ 書 き ]

  ┌─────────────────────┐
  │                     │
  │      (void)         │
  │   真っ白な色紙       │
  │                     │
  └─────────────────────┘

  作成する → modal /board/create
  参加する → input[board_id]
```

- URL に board ID がない場合: void（empty state）を表示
- 「寄せ書きを作成」→ Supabase `boards` テーブルに insert → `/board/:id` へ遷移
- 「参加する」→ board ID 入力 → `/board/:id` へ遷移

### `/board/:id` — ボード画面（Void → 充足）

```
  ┌─ board-menu ─────────┐
  │           [ボード情報] │
  ├──────────────────────┤
  │                      │
  │   ┌── 色紙 ──────┐   │
  │   │   (回転)      │   │
  │   │   メッセージ   │   │
  │   └───────────────┘   │
  │                      │
  │   空きの場所をタップ   │
  └──────────────────────┘
```

- 既存の yosegaki.html の UI をそのまま Vue コンポーネント化
- Nuxt 3 のサーバールート経由で Supabase から初期データ取得（SSR）
- その後 Supabase Realtime でリアルタイム同期

---

## Data Layer

### Supabase Tables

```sql
-- boards
CREATE TABLE boards (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  password    TEXT,
  display_title TEXT,      -- 色紙中央の名前（例: 平井さん）
  display_phrase TEXT,     -- 色紙中央のフレーズ（例: お疲れ様でした）
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- messages
CREATE TABLE messages (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  board_id    UUID REFERENCES boards(id) ON DELETE CASCADE,
  slot_idx    SMALLINT NOT NULL CHECK (slot_idx >= 0 AND slot_idx < 24),
  text        TEXT NOT NULL,
  font        TEXT,
  color       TEXT,
  font_size   SMALLINT DEFAULT 18,
  client_id   TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_messages_board_id ON messages(board_id);
CREATE INDEX idx_messages_created_at ON messages(board_id, created_at);

-- slot_locks（排他ロック用）
CREATE TABLE slot_locks (
  board_id    UUID REFERENCES boards(id) ON DELETE CASCADE,
  slot_idx    SMALLINT NOT NULL,
  client_id   TEXT NOT NULL,
  locked_at   TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (board_id, slot_idx)
);

-- 30秒で自動 expire（アプリ層で確認）
```

### Nuxt Server Routes

Supabase クライアントはサーバーサイドでのみ初期化。クライアントには Supabase anon key を露出させず、Nuxt server routes を経由する。

```
Client (Vue) ──fetch──→ Nuxt Server Route ──supabase-js──→ Supabase
                                │
                          Realtime 購読は?
                                │
Client (Vue) ─── supabase-js（anon key 直接）───→ Supabase Realtime
```

- **CRUD**: すべて Nuxt サーバールート経由（API key 非露出）
- **Realtime**: クライアントから Supabase Realtime に直接接続（anon key 必要。RLS で読み取りのみ許可）
- **排他ロック**: Nuxt サーバールート経由で `slot_locks` テーブルを操作

---

## Component Tree

```
App.vue
├── NuxtLayout
│   ├── NuxtPage
│   │   ├── index.vue
│   │   │   ├── HeroSection (void state)
│   │   │   ├── CreateBoardButton
│   │   │   └── JoinBoardInput
│   │   │
│   │   └── board/[id].vue
│   │       ├── BoardMenu (右上)
│   │       ├── Outer (色紙コンテナ)
│   │       │   ├── Inner (回転)
│   │       │   │   ├── WashiPaper.vue (Canvas 背景)
│   │       │   │   ├── OvalFrame.vue (SVG 楕円 + 装飾文字)
│   │       │   │   └── MessageLayer
│   │       │   │       └── MessageSlot.vue × 24 (文字配置)
│   │       │   └── WriteZone.vue (上部ライトグロウ + 入力)
│   │       ├── HiddenInput (透明 input)
│   │       ├── HintToast (ヒント/トースト)
│   │       └── BoardPanel (モーダル)
│   │
│   └── NuxtLoadingIndicator
```

---

## Migration Steps

| Phase | Task | Est. |
|-------|------|------|
| **P0: Init** | `npx nuxi init` + Supabase project create + テーブル作成 | 1h |
| **P0: Core** | 色紙UI コンポーネント移植（WashiPaper, OvalFrame, MessageSlot） | 4h |
| **P0: Write** | WriteZone + 入力機構 + 回転アニメーション | 3h |
| **P1: Data** | Nuxt server routes: CRUD + Supabase 接続 | 3h |
| **P1: Real** | Supabase Realtime 購読 + 排他ロック | 2h |
| **P1: Board** | ボード作成/参加/管理パネル | 2h |
| **P2: Delete** | メッセージ削除（長押し → ✕ ボタン） + 色変更 + ピンチリサイズ | 2h |
| **P2: Polish** | アニメーション調整、ハプティクス、モバイル最適化 | 2h |
| **P2: Deploy** | Cloudflare Pages または Firebase Hosting にデプロイ | 1h |
| **P3: Auth** | Supabase Auth（匿名セッション or OAuth） | 2h |
| **P3: Admin** | 管理画面（パスワード保護ボード管理） | 3h |
| **P3: Test** | E2E + パフォーマンステスト | 2h |

**Total**: ~27h

---

## Component Design (Void Pattern)

### State Machine

```
                    tap
  ┌──────────┐  ────────→  ┌──────────┐
  │  VOID    │             │ ROTATING │
  │ (empty)  │  ←────────  │ (0.72s)  │
  └──────────┘   cancel    └────┬─────┘
                                │ timeout
                                ▼
                         ┌──────────┐
                         │ WRITING  │
                         │ (input)  │
                         └────┬─────┘
                            /     \
                      Enter        Esc
                       ▼            ▼
                  ┌──────────┐  ┌──────────┐
                  │ PLACED   │  │  VOID    │
                  │ (filled) │  │ (empty)  │
                  └──────────┘  └──────────┘
```

### Transition Design

- **VOID → ROTATING**: 色紙が回転（0.72s cubic-bezier）
- **ROTATING → WRITING**: 上部にライトグロウがフェードイン。カーソル点滅
- **WRITING → PLACED**: 文字が1文字ずつ放射状に現れる（180ms スタガード遅延）
- **PLACED → VOID**: 削除時にスロットが空き、void に戻る

---

## nuxt.config.ts 方針

```ts
export default defineNuxtConfig({
  modules: ['@nuxtjs/tailwindcss'],
  ssr: true,
  nitro: {
    preset: 'cloudflare-pages', // or 'firebase'
  },
  runtimeConfig: {
    supabaseUrl: '',
    supabaseServiceKey: '', // server-only
    public: {
      supabaseAnonKey: '',  // client (Realtime only)
    },
  },
})
```

---

## Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Nuxt 3 SSR + Supabase 接続のレイテンシ | 初期データを Nitro server route で取得し、CSR はキャッシュ。KV 導入も検討 |
| Supabase 無料枠（500MB DB, 200 concurrent Realtime） | 小規模利用なら十分。スケール時にプランアップ |
| 既存 Vanilla JS からの移行コスト | UI はそのまま Vue コンポーネント化。ロジックは composable に分割。段階的移行可 |
| Realtime anon key 露出 | RLS で読み取り専用 + レート制限。書き込みは必ず server route 経由 |

---

## Prerequisites

- [ ] Node.js 22+
- [ ] `npm create nuxt@latest` でプロジェクト生成
- [ ] Supabase アカウント + プロジェクト作成
- [ ] Supabase `boards`, `messages`, `slot_locks` テーブル作成
- [ ] Supabase RLS ポリシー設定（読み取り: public, 書き込み: server-only）
- [ ] デプロイ先決定: Cloudflare Pages SSR or Firebase Hosting + Cloud Functions

