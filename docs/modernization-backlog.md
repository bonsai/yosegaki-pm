# モダナイゼーションバックログ

> オントロジーギャップ分析 (`docs/ontology.md` × V2実装) に基づく。
> 4フェーズ構成。Phase1→2→3→4 の順に着手。

---

## Phase 1: セキュリティ 🔴

| 優先度 | Issue | 現状 | 対象 | モダナイゼーション観点 |
|--------|-------|------|------|------------------------|
| P0 | Firestore全開放修正 | 新規 | V2 | `firestore.rules` が `allow read,write:if true`。最小権限の原則 |
| P0 | config.js APIキーSecret化 | #33 CLOSED | V2 | リポジトリに生キー。GitHub Secrets + deploy.yml で注入 |
| P0 | パスワードハッシュ化 | 新規 | V2 | boards.password が平文保存。Firebase Auth 導入までの暫定対応 |
| P1 | 削除UI改善 | 新規 | V2 | ホバー依存→確定的UIに。ゴーストタップ問題残存 |

**Phase 1 目標**: 全世界読み書き可能状態の解消。最低限のセキュリティ確保。

---

## Phase 2: コア状態機械 🟠

| 優先度 | Issue | 現状 | 対象 | モダナイゼーション観点 |
|--------|-------|------|------|------------------------|
| P1 | Slot.state 実装 | #1 OPEN | V1 | `occupied:bool`→`VOID/ROTATING/WRITING/PLACED` enum。Slot状態可視化 |
| P1 | 排他ロック本実装 | 新規 | V2 | `acquireLock()` が常にtrue。Firestore連携+expires_at |
| P1 | Board.status 自動遷移 | 新規 | V2 | 全Slot埋まったらcompleted。created/in_progress/completed/archived |
| P1 | Slot回転アニメーション | #2 OPEN | V1 | VOID→ROTATING→WRITING のアニメーション遷移実装 |
| P2 | スロット状態可視化 | (#1 に包含) | V1 | 空/編集中/完了のUI区別。デコレーション |

**Phase 2 目標**: オントロジー定義の状態機械をコードに反映。競合のない協調編集基盤。

---

## Phase 3: エンティティ補完 🟡

| 優先度 | Issue | 現状 | 対象 | モダナイゼーション観点 |
|--------|-------|------|------|------------------------|
| P1 | モバイルレスポンシブ | #3 OPEN | V1 | viewport+44pxタップ領域+キーボード対応 |
| P2 | フォント/カラー選択UI | #4 OPEN | V1 | ランダム固定→ユーザー選択可能に |
| P2 | エラーハンドリング統一 | #5 OPEN | V1 | トースト/ローディング/オフライン |
| P2 | ボード管理UI | #6 OPEN | V1 | タイトル編集/削除/完了表示/テーマ |
| P2 | display_title/phrase 動的化 | 新規 | V2 | SVG直書きハードコード→Boardデータ駆動 |
| P2 | Theme導入 | 新規 | V2 | 和紙色/枠線/背景のテーマ選択 |
| P2 | author_name 表示 | 新規 | V2 | メッセージに署名表示 |
| P3 | layout_type 拡張 | 新規 | V2 | oval固定→circle/free対応 |
| P2 | コード改善共通 | — | V1/V2 | ハードコード値の定数化/文字化け修正/config.js削除 |

**Phase 3 目標**: オントロジー全エンティティの最低限実装。V2 がプロダクトとして成立。

---

## Phase 4: 認証 + 権限 🔵

| 優先度 | Issue | 現状 | 対象 | モダナイゼーション観点 |
|--------|-------|------|------|------------------------|
| P1 | Firebase Auth 導入 | #35 OPEN | V2 | SDK導入+プロジェクト設定 |
| P1 | サインアップ/サインインUI | #36 OPEN | V2 | メール+パスワード認証 |
| P1 | ロールベースアクセス制御 | #37 OPEN | V2 | admin/editor/viewer + Security Rules |
| P2 | セッション管理 | #38 OPEN | V2 | 永続化+トークンリフレッシュ |
| P2 | Googleログイン | #39 OPEN | V2 | OAuth設定+UI |
| P2 | パスワードリセット | #40 OPEN | V2 | リセットメール+UI |

**Phase 4 目標**: 認証基盤完成。Firestore Security Rules をロールベースに強化。

---

## クロスフェーズ共通タスク

| Issue | 現状 | 対象 | 備考 |
|-------|------|------|------|
| `config.js` 削除 | 新規 | V1 | Supabase廃止後の死骸。削除のみ |
| テスト導入 | 新規 | V1/V2 | 最低限スモークテスト |
| 責務分離 (app.js分割) | 新規 | V1/V2 | 738行1ファイル→view/model/controller |
| 文字化け修正 | 新規 | V2 | cp932由来のコメント/トースト文字化け全滅 |

---

## 現状サマリ (フェーズ別)

```
Phase 4: 認証 ─── #35 #36 #37 #38 #39 #40  (6 OPEN)
Phase 3: 補完 ─── #1 #2 #3 #4 #5 #6 +4新規 (10)
Phase 2: 状態機械 ─ #1 #2 +2新規 (4)
Phase 1: セキュリティ ─ 0 OPEN +3新規 (3)
```
