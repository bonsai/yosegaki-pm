# 寄せ書き色紙 Ontology

> 定義: 2026-06-27  
> 管理: 各repo issue は GitHub、統合管理は yosegaki.db (ローカル)

---

## 1. ドメイン概観

寄せ書き色紙アプリのドメインは、現実世界の「色紙に寄せ書きを集める」行為をデジタルに再現する。
24スロットの楕円軌道上にメッセージを円弧状に配置し、協調書き込みを可能にする。

## 2. コアエンティティ

### 2.1 Board (ボード／色紙)

1枚の色紙に対応するデジタルコンテナ。

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| id | string | ✅ | 一意識別子 |
| title | string | ✅ | 表題（例: 「平井さんの寄せ書き」） |
| password | string? | | 管理パスワード |
| display_title | string? | | 中央に表示する名前（例: 「平井さん」） |
| display_phrase | string? | | 中央に表示するフレーズ（例: 「お疲れ様でした」） |
| status | enum | ✅ | created / in_progress / completed / archived |
| layout_type | enum | ✅ | oval / circle / free |
| creator_id | string? | | 作成者（認証導入後） |
| created_at | datetime | ✅ | 作成日時 |
| completed_at | datetime? | | 完成日時（全スロット埋まった日時） |
| theme | Theme? | | 色紙のテーマ設定 |

#### Board Status マシン

```
created → in_progress → completed → archived
```

- **created**: 生成されたが未使用
- **in_progress**: 書き込み受付中
- **completed**: 全24スロット埋まった
- **archived**: アーカイブ（編集不可）

### 2.2 Slot (スロット)

色紙上のメッセージ配置単位。物理的には「一人一つの書き込む場所」。

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| index | int (0-23) | ✅ | スロット番号 |
| board_id | string | ✅ | 所属ボード |
| state | enum | ✅ | void / rotating / writing / placed |
| angle | float | ✅ | 色紙上の角度（度） |
| occupied | bool | ✅ | メッセージ有無 |

#### Slot State Machine (Void Pattern)

```
stateDiagram-v2
    [*] --> VOID
    VOID --> ROTATING : tap
    ROTATING --> WRITING : animation end
    WRITING --> PLACED : Enter
    WRITING --> VOID : Esc
    PLACED --> VOID : delete
    VOID --> [*] : board archived
```

### 2.3 Message (メッセージ)

スロットに書き込まれた個々のメッセージ。文字単位で円弧上に配置される。

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| id | string | ✅ | 一意識別子 |
| board_id | string | ✅ | 所属ボード |
| slot_idx | int (0-23) | ✅ | 所属スロット |
| text | string | ✅ | メッセージ本文 |
| font | Font | ✅ | フォント |
| color | Color | ✅ | 文字色 |
| font_size | int | ✅ | フォントサイズ(px) |
| client_id | string | ✅ | 書き込んだクライアント |
| author_name | string? | | 署名（任意） |
| created_at | datetime | ✅ | 書き込み日時 |

### 2.4 SlotLock (スロットロック)

同時編集を防ぐための排他ロック。

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| board_id | string | ✅ | ボードID |
| slot_idx | int | ✅ | スロット番号 |
| client_id | string | ✅ | ロック保持者 |
| locked_at | datetime | ✅ | ロック開始時刻 |
| expires_at | datetime | ✅ | 自動期限（30秒後） |

### 2.5 Theme (テーマ)

色紙の外観設定。

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| id | string | ✅ | テーマID |
| name | string | ✅ | 表示名（例: 「古典和紙」「桜」「和モダン」） |
| washi_color | string | ✅ | 和紙ベース色 |
| border_style | enum | ✅ | gold / silver / none |
| border_color | string | ✅ | 枠線色 |
| slot_bg_empty | string | ✅ | 空きスロット背景色 |
| slot_bg_filled | string | ✅ | 埋まりスロット背景色 |
| accent_color | string | | アクセント色 |

### 2.6 User (ユーザー) — V2以降

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| id | string | ✅ | ユーザーID（Firebase Auth UID） |
| email | string | ✅ | メールアドレス |
| display_name | string? | | 表示名 |
| role | enum | ✅ | admin / editor / viewer |
| created_at | datetime | ✅ | アカウント作成日時 |

### 2.7 Subscription (サブスクリプション) — V3

| 属性 | 型 | 必須 | 説明 |
|------|-----|------|------|
| id | string | ✅ | サブスクリプションID |
| user_id | string | ✅ | ユーザーID |
| plan | enum | ✅ | free / pro / enterprise |
| status | enum | ✅ | active / canceled / past_due |
| current_period_start | datetime | ✅ | 現在の期間開始 |
| current_period_end | datetime | ✅ | 現在の期間終了 |
| stripe_customer_id | string? | | Stripe顧客ID |

## 3. レイアウトモデル

### 3.1 楕円レイアウト（現行）

```
パラメータ:
- 中心: (CX, CY) = (280, 280)
- 楕円半径: (rx, ry) = (88, 62) — inner edge
- スロット数: 24
- 配置: 等角度 (360/24 = 15度間隔)
- 文字軌道: 内側から外側へ螺旋状

文字位置計算:
  angle = slot_idx * (360/24)  // スロット角度
  aRad  = angle * PI / 180
  R_INNER = ovalEdge(aRad) + 10
  r = R_INNER + charIndex * fontSize * 1.72 + fontSize * 0.5
  x = CX + sin(aRad) * r
  y = CY - cos(aRad) * r
```

### 3.2 円形レイアウト（将来）

```
- 中心: (CX, CY)
- 半径: R
- スロット数: 任意 (8/12/16/24)
```

## 4. 現状×オントロジーギャップ

| 概念 | V1 | V2 | V3 | ギャップ |
|------|----|----|----|---------|
| Board.status | ❌ | ❌ | ❌ | 状態管理なし |
| Slot.state (Void) | ❌ | ⚡暗黙 | ⚡暗黙 | 明示的なステートマシン化が必要 |
| Theme | ❌ | ❌ | ❌ | テーマ概念なし |
| User/Role | ❌ | ❌ | ❌ | 未実装 |
| Subscription | ❌ | ❌ | ❌ | 未実装 |
| author_name | ❌ | ❌ | ❌ | 署名なし |
| display_title/phrase | ❌ | ❌ | ✅ shikishi | V1/V2に未実装 |
| SlotLock.expires_at | ❌ | ❌ | ❌ | タイムアウト未実装 |
| Board.completed_at | ❌ | ❌ | ❌ | 完成日時なし |

## 5. バージョン別解消方針

| V | フォーカス | 主要ISSUE |
|---|-----------|-----------|
| V1 | UI解消 | Slot状態可視化 / アニメーション / レスポンシブ / エラーハンドリング |
| V2 | 認証 | Firebase Auth / ログインUI / ロール管理 |
| V3 | 課金 | Stripe連携 / サブスクリプション / プラン管理 |

## 参照

- ADR-001: V1/V2/V3 分離戦略
- ADR-002: shikishi Supabase → D1 移行計画
- PRD: 製品要件定義
- V3_PLAN.md: Nuxt 3 + Supabase 詳細設計
