# MoviesRank 改善チケット一覧

多次元監査（バグ/セキュリティ・性能・機能不足・UI/UX・アクセシビリティ・テスト/設定・コード品質の7次元）で洗い出した84件の指摘を、敵対的検証で83件に確定。重複を統合し、優先度付けした一覧です。

- **優先度の考え方**: `実害(可用性/データ整合) × ユーザー価値 ÷ 実装コスト`。確定バグ・高頻度の表示崩れ・主要導線の欠落を上位に置く。
- **規模**: S=小（〜数十行）/ M=中 / L=大。
- 検証メモ付き原データは `tasks/wut2kitek.output`（監査ワークフロー出力）参照。

> 補足: 監査の生成段階で「`icon()`ヘルパー未定義で投稿/編集フォームが500」というCRITICAL候補が出たが、独立検証で**誤検知**と判明（font-awesome-sass 5.15.1 が `icon` ヘルパーをrailtieでActionViewに自動include）。確定83件はいずれも実コードで根拠を確認済み。

---

## ✅ 実装状況（このセッションで対応済み）

P0は全件、P1の主要項目を実装し、テスト42件パス・実機（モバイル/デスクトップ）で検証済み。**未コミット**（規約によりコミットは確認後）。

| 状態 | チケット | 補足 |
|------|----------|------|
| ✅ | MR-001 | indexのカテゴリ行をDBの実カテゴリから動的生成（実機でアクション/ドラマ/アニメ表示確認） |
| ✅ | MR-002 | User nickname必須化＋登録フォームrequired＋users#showのnil安全化 |
| ✅ | MR-003 | image presenceをカスタム検証化＋**新規発見の隠れバグ**（`movies.image`がNOT NULLでフォーム投稿が500）をマイグレーションで修正 |
| ✅ | MR-004 | プレースホルダを外部依存ゼロのインラインSVGに置換 |
| ✅ | MR-005 | ライブ検索のDOM生成を`.grid-card`構造に統一＋jbuilderにcategory追加 |
| ✅ | MR-006 | 死リンク撤去、ナビに映画一覧/ランキング/マイリスト導線 |
| ✅ | MR-007 | `<html lang="ja">` |
| ✅ | MR-008 | 一覧/検索/ランク/プロフィールに`with_attached_image`（N+1対策） |
| ✅ | MR-009 | 空キーワード検索は0件返却 |
| ✅ | MR-010 | production.rbでforce_ssl有効化＋assume_ssl切替 |
| ✅ | MR-011 | `_responsive.scss`でモバイル対応（ヘッダー/詳細/グリッド/フォーム、実機検証済み） |
| ✅ | MR-012 | 全映画カタログページ（`movies#catalog`） |
| ✅ | MR-013 | kaminariページネーション（カタログ24件/頁、実機で2頁確認） |
| ✅ | MR-014 | カタログのソート（新着/人気/タイトル）・カテゴリ絞り込み |
| ✅ | MR-015 | DB/全テーブルをutf8mb4へ移行＋絵文字保存テスト |
| ✅ | MR-016 | 検索フォームにaria-label、アイコンにaria-hidden |
| ✅ | MR-017 | コメント/検索結果にaria-live |
| ✅ | MR-018 | グローバル`:focus-visible`でフォーカス可視化 |
| ✅ | MR-019 | 「98% マッチ」固定値を撤去（いいね数表示に置換） |
| ✅ | MR-020 | 投稿/編集フォームにラベル（visually-hidden） |
| ✅ | MR-021 | GitHub Actions CI（テスト＋アセットprecompile） |
| ✅ | MR-022 | カテゴリ入力にdatalist（既存カテゴリ候補） |
| ✅ | MR-024 | コメント空状態＋投稿日時表示＋rank-numberの`data-rank` |
| ✅ | MR-033 | AGENTS.mdを実装に整合（ERB/ActiveStorage/Stimulus/importmap） |
| ✅ | MR-036 | 未ログイン時のいいねをログインリンク化（フォーカス可能） |
| ✅ | 一部 | MR-028/076（Movie CRUD・認可・dependent destroyのテスト追加） |

**未対応の主な残（次バッチ候補）**: MR-022の本格的なカテゴリ正規化、MR-023（いいね楽観的更新）、MR-025（alert→トースト統一）、MR-026/027（プロフィール編集・星評価）、MR-028（CSP/レート制限の残り）、MR-029（brakeman/rubocop）、MR-030/031（公開範囲・CSSインジェクション）、MR-034/035（デッドコード削除・SCSSリネーム）、MR-037（i18n）、MR-038（ランドマーク/スキップリンク/コントラスト）、MR-039（テスト拡充）。

---

## P0 — 即対応（確定バグ・主要導線欠落・低コスト高価値）

| ID | カテゴリ | 規模 | 内容 | 受け入れ条件 |
|----|----------|------|------|--------------|
| MR-001 | bug | M | **カテゴリ別行が言語不一致で空になる**: `index`が英語固定値`'Action'/'Animation'/'Drama'`で絞り込むが、seedは日本語(`アクション/アニメ/ドラマ`)で保存→ホームのジャンル行が常に空。さらにカテゴリは自由入力で表記揺れ。 | ホームにジャンル別行が実データで表示される。DBに存在するカテゴリから動的に行を生成。 |
| MR-002 | bug | S | **nickname未検証でusers#showが500**: nicknameがnullableかつ無検証。空登録すると`@user.nickname[0]`が`nil[0]`でNoMethodError→500。 | 空nicknameで登録できない／既存null時もプロフィールが落ちない。 |
| MR-003 | bug | M | **シード映画(全100件)が編集不能**: `validates :image, presence`がActiveStorage添付を要求するが、seedは文字列カラムにURLを入れ添付なし。タイトル変更だけでもupdateが画像必須で失敗。 | 添付 or 外部URL文字列のどちらかがあれば保存可。シード映画をタイトルだけ編集して保存できる。 |
| MR-004 | bug/uiux | S | **プレースホルダ画像が停止サービス**: `via.placeholder.com`は現在停止。画像未設定の映画/ヒーロー背景が割れる。 | ローカル同梱SVG等の外部依存ゼロのプレースホルダに置換。 |
| MR-005 | bug/uiux | M | **ライブ検索結果が無スタイル**: `search_controller.js`が`.content`系を生成するが、検索ページは`.grid-card`系でSCSS定義も`.content`に無い→入力した瞬間にレイアウト崩壊。 | ライブ検索結果が静的表示と同じ`.grid-card`グリッドで表示される。 |
| MR-006 | feature/uiux | S | **ヘッダーの死リンク＆ランキング導線欠如**: nav4項目が`href="#"`。実装済みのrankページへの導線がアプリ内に一切ない。 | 死リンクを実ルートに接続 or 撤去。ランキングへ常時到達可能。 |
| MR-007 | a11y | S | **html lang属性なし**: 全ページ日本語なのに`<html>`にlangなし→SRが言語判別不可（WCAG 3.1.1 レベルA）。 | `<html lang="ja">`。 |
| MR-008 | perf | S | **画像のN+1**: 一覧/検索/ランク/プロフィールで`with_attached_image`未使用→ActiveStorage添付ありの映画でN+1。 | 該当クエリに`with_attached_image`を付与。 |
| MR-009 | perf | S | **検索が空キーワードで全件返す**: `Movie.search`がblank時`all`→検索ページで全件ロード。 | 空キーワード時は結果0件＋入力促し、または件数制限。 |
| MR-010 | security/config | S | **本番でforce_ssl無効＋production.rbが旧形式**: 認証Cookie/CSRFが平文送信されうる。HSTS/secure cookieも無し。 | `force_ssl`(プロキシ終端時は`assume_ssl`併用)を有効化。 |

## P1 — 重要（利便性・UX・基盤）

| ID | カテゴリ | 規模 | 内容 | 受け入れ条件 |
|----|----------|------|------|--------------|
| MR-011 | uiux | L | **モバイル非対応**: SCSS全体でメディアクエリが`_rank.scss`の1つのみ。ヘッダー/ヒーロー/横スクロール行/フォーム/詳細が全て非レスポンシブ。 | 768px以下でヘッダー折りたたみ、主要画面が縦積みで破綻しない。 |
| MR-012 | feature | M | **全映画カタログページがない**: indexは限定行のみ、全件を一覧する手段が無い。 | `/movies`相当の全件ページ（ページネーション付き）。 |
| MR-013 | feature/perf | M | **ページネーション未導入**: kaminari導入済みだが未使用。検索/カタログ/プロフィールが全件ロード。 | 主要一覧にkaminariページネーション。 |
| MR-014 | feature | M | **ソート/フィルタが無い**: 並び替え(新着/人気)・カテゴリ絞り込みができない。 | カタログ/一覧でソート・カテゴリ絞り込み可能。 |
| MR-015 | bug/config | M | **utf8mb4移行**: 全テーブルutf8mb3で絵文字(4バイト)保存時にエラー/欠落。コメント・タイトルが落ちる。 | utf8mb4へマイグレーション。database.ymlもutf8mb4。絵文字コメント投稿が通る。 |
| MR-016 | a11y | S | **検索フォームのlabel/aria欠如**: 入力欄にlabelなしplaceholderのみ、送信ボタンがアイコンのみで名前なし。 | aria-label付与、アイコンにaria-hidden。 |
| MR-017 | a11y | M | **動的更新がSRに通知されない**: コメント追加/ライブ検索結果にaria-liveなし。 | 更新領域にaria-live="polite"。 |
| MR-018 | a11y | S | **フォーカスが不可視**: resetで`outline:0`を全要素に適用し代替なし→キーボード操作不能。 | グローバル`:focus-visible`を追加。 |
| MR-019 | uiux | S | **「98% マッチ」固定の偽データ**: 全カード/ヒーロー/詳細に同一値。信頼性低下。 | 撤去 or 実データ(いいね数等)に置換。 |
| MR-020 | a11y | S | **投稿/編集フォームのlabel欠如**: title/director/category/youtube/detailがplaceholderのみ。 | 各項目にlabel(sr-only可)。 |
| MR-021 | test | M | **CI不在＋Movie CRUD/認可テスト欠如**: 回帰検知が機能していない。`authorize_movie_owner!`等が未検証。 | GitHub Actions CI追加。Movie作成/更新/削除/認可のテスト追加。 |
| MR-022 | feature | M | **コメント編集・削除ができない**: 投稿後に修正/取消不可。 | 本人のみコメント編集・削除可。 |

## P2 — 改善・拡張（中長期）

| ID | カテゴリ | 規模 | 内容 |
|----|----------|------|------|
| MR-023 | uiux | M | いいねを楽観的更新(Stimulus/turbo_stream)にしてページリロードを排除 |
| MR-024 | uiux | S | コメント空状態の表示／投稿日時の表示／rank-numberの`data-rank`属性付与 |
| MR-025 | uiux/a11y | S | `alert()`を既存`.notifications`トーストに統一 |
| MR-026 | feature | S | プロフィール編集導線／マイリスト直接導線の追加 |
| MR-027 | feature | L | 星評価(スコア)機能 |
| MR-028 | security | M | CSP定義／認証・コメント・いいねのレート制限(rack-attack) |
| MR-029 | security | S | brakeman/rubocop等の静的解析を導入 |
| MR-030 | security | M | users#showの公開範囲見直し(いいね履歴の非公開化/RecordNotFound→404) |
| MR-031 | security | M | 画像URL文字列のCSS `url()`埋め込みのエスケープ(CSSインジェクション対策) |
| MR-032 | perf | S | `likes_count`/`category`インデックス追加 |
| MR-033 | docs | M | **AGENTS.md全面更新**(Haml/CarrierWave/jQuery/Sprockets/Kaminari等の旧記述を実装に合わせる) |
| MR-034 | quality | S | デッドコード削除(空partial`_lists`/`_contents`/空SCSS3件/空helper5件/`hello_controller.js`) |
| MR-035 | quality | S | `_registraiton.scss`のスペル修正リネーム |
| MR-036 | config | S | `.env.example`/READMEに本番必須env(DB password/MASTER_KEY)追記 |
| MR-037 | quality | M | i18n整備(ロケールファイル化) |
| MR-038 | a11y | M | ランドマーク(nav/main)＋スキップリンク／補助テキストのコントラスト改善／アイコンのaria-hidden |
| MR-039 | test | M | image_url3分岐/youtube正規化/ランキング境界/dependent destroy/JSON応答のテスト拡充 |
| MR-040 | quality | S | アイコン実装の統一／show.html.erbの重複整理 |

---

## 実装順序

1. **P0バッチ**（MR-001〜010）: 確定バグ修正＋低コスト高価値。テスト/precompileで検証してコミット。
2. **P1バッチ**（MR-011〜022）: レスポンシブ・カタログ・ページネーション・a11y・CI。
3. **P2**: 機能拡張・運用整備を順次。
