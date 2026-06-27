# 引き継ぎ文書 — yosegaki / 色紙寄せ書き

> 作成: 2026-06-20  
> 状態: **一時停止**（yotei 優先のため）  
> 次担当: 再開時はこの文書から読み始める

---

## プロジェクト全体像

色紙型リアルタイム寄せ書きアプリ。24スロット放射状配置、複数人同時書き込み、Firestore 排他ロック。

### バージョン構成（2026-06-20 確定）

| バージョン | repo | スタック | 状態 |
|---|---|---|---|
| V1 | `bonsai/yosegaki-v1` | Firebase + Vanilla JS | 🟢 **本番稼働** |
| V2 | `bonsai/yosegaki-v2` | CF Pages + TypeScript + Vite + KV | 🔵 scaffold のみ |
| V3 (shikishi) | `bonsai/shikishi` | Nuxt 3 + Supabase | 🔵 scaffold のみ |

### V1 本番 URL

- https://yose-gaki.web.app （Firebase Hosting / yosegaki-web project）

---

## V1 ディレクトリ構造

```
C:\Users\dance\Documents\MEGA\yosegaki-v1\   ← 新 V1 リポジトリ（クリーン）
C:\Users\dance\Documents\MEGA\yose-gaki\     ← 旧作業ディレクトリ（アーカイブ）
  └── src/    ← V1 と同内容（yosegaki-web repo にリンク）
```

---

## 残タスク（優先順）

### 🔴 高優先（V1 に対して）

| # | 内容 | 場所 |
|---|---|---|
| #27 | iOS Safari の `hiddenInput.focus()` 動作確認 | yosegaki-web |
| #30 | Smoke test チェックリスト実施 | yosegaki-web |
| — | Firestore rules を本番用に締める（現在 full open） | `firestore.rules` |
| — | Firebase billing アラート設定（Blaze プラン、未設定） | Firebase Console |

### 🟡 中優先（V2 着手時）

| # | 内容 |
|---|---|
| — | `wrangler kv namespace create YOSEGAKI` → `wrangler.toml` に ID 記入 |
| — | CF Pages プロジェクト作成 (`wrangler pages project create yosegaki-v2`) |
| — | V1 機能 (排他ロック・アニメーション) を TypeScript に移植 |
| — | GitHub Secrets: `CF_API_TOKEN`, `CF_ACCOUNT_ID` 設定 |
| #33 | SUPABASE_URL / SUPABASE_ANON_KEY secrets (V3 shikishi 用) |

### ⚪ 低優先（V3 shikishi 用）

- Supabase テーブル設計（boards / messages / slot_locks）
- Nuxt + Supabase Realtime 接続
- Cloudflare Pages SSR デプロイ設定

---

## 重要な注意点

1. **`config.js` は .gitignore** — 各環境で手動配置 or CI 経由
2. **Firestore rules が full open** — 本番前に必ず締めること
3. **`yose-gaki/` は旧 monorepo** — `v0/`, `v1/`, `v2/` の混在履歴あり。参照のみ
4. **V1 と V2 は別 repo** — push 先を間違えないこと
5. **Firebase billing** — Blaze プラン稼働中。アラート未設定

---

## 再開時の手順

```powershell
# V1 本番確認
cd C:\Users\dance\Documents\MEGA\yosegaki-v1
firebase deploy   # FIREBASE_TOKEN 必要

# V2 開発開始
cd C:\Users\dance\Documents\MEGA\yosegaki-v2
npm install
wrangler kv namespace create YOSEGAKI
npm run dev
```

---

## 関連リンク

- Firebase Console: https://console.firebase.google.com/project/yosegaki-web/overview
- V1 repo: https://github.com/bonsai/yosegaki-v1
- V2 repo: https://github.com/bonsai/yosegaki-v2
- V3 repo: https://github.com/bonsai/shikishi
- 旧 repo (archive): https://github.com/bonsai/yosegaki-web

