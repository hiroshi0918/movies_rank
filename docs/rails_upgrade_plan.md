# Rails Upgrade Plan

## 概要

- 作成日: 2026-03-22
- 現在の構成:
  - Ruby `2.6.10`
  - Rails `5.2.4.1`
  - MySQL
  - Sprockets
  - CoffeeScript
  - Turbolinks
  - jQuery
- 目標:
  - Ruby `3.3` または `3.4`
  - Rails `8.1.2`

このドキュメントは、現行の Rails 5.2 アプリを最新安定版の Rails 8.1.2 まで段階的に引き上げるための PR 単位の作業計画です。

方針は次の通りです。

- Rails は major / minor を飛ばさずに上げる
- Ruby は Rails の要求バージョンに合わせて段階的に上げる
- `config.load_defaults` はすぐに最新へ上げず、各段階で互換性を確認しながら進める
- asset 周りの古い構成は Rails 本体と分けて整理する
- 各 PR は boot / DB / test / asset の確認条件を持つ

## 現状の主な技術的負債

- `Gemfile` が Rails 5 系の構成に強く依存している
  - `puma ~> 3.11`
  - `sass-rails`
  - `coffee-rails`
  - `turbolinks`
  - `uglifier`
  - `chromedriver-helper`
  - `spring`
- `app/assets/javascripts/application.js` が `jquery`, `rails-ujs`, `turbolinks`, `require_tree` ベース
- `app/javascript` は未導入
- Rails 5.2 と current OpenSSL の相性回避設定が development / test に入っている
- system Ruby 起因の問題が出ていたため、開発環境の再現性に注意が必要

## PR 一覧

### PR1: `baseline-safety-net`

目的:
- 現行 Rails 5.2 の挙動を固定する

主な作業:
- 主要ユースケースの request/system テストを追加する
- 既存テストの通過を確認する
- 手動確認項目を整理する

対象機能:
- ログイン / ログアウト
- 映画投稿
- 一覧表示
- コメント投稿
- いいね
- マイページ

完了条件:
- `bundle exec rails test` が通る
- 主要導線の手動確認項目が揃う

### PR2: `dev-env-normalization`

目的:
- 開発環境の前提を明文化して、upgrade 作業時の再現性を確保する

主な作業:
- `README.md` と `bin/setup` を整理する
- `MYSQL_USERNAME`, `MYSQL_PASSWORD`, `MYSQL_HOST`, `MYSQL_PORT` 前提を明文化する
- `.env.example` の追加を検討する
- Ruby バージョン管理ツール導入方針を決める

完了条件:
- 新しい開発環境で DB 作成から起動までの再現手順が揃う

### PR3: `ruby-2-7-and-rails-5-2-latest`

目的:
- 現行 major のまま土台を新しくする

主な作業:
- Ruby を `2.7.x` に更新する
- Rails 5.2 を最新 patch に寄せる
- 互換性のある周辺 gem を更新する

更新候補:
- `mysql2`
- `bootsnap`
- `web-console`
- `listen`
- `puma`

完了条件:
- boot, DB, test が通る
- 主要画面が現行同等に動作する

### PR4: `rails-6-1-and-zeitwerk`

目的:
- Rails 6 系へ上げ、Zeitwerk に対応する

統合元:
- 旧 PR4 `rails-6-0-upgrade`
- 旧 PR5 `rails-6-1-and-zeitwerk`

主な作業:
- Rails を `6.0` 経由で `6.1` へ上げる
- `rails app:update` 差分を必要最小限で反映する
- `config.load_defaults` は段階的に扱う
- `bin/rails zeitwerk:check` を通す
- autoload / naming / constant 解決のズレを修正する
- secrets / credentials / config 差分を整理する

主なリスク:
- autoload 対象の定数名とファイル名の不整合
- initializer の読み込み順依存
- 旧 config のままでは起動はしても warning が大量に出る可能性

完了条件:
- `bin/rails zeitwerk:check` が通る
- `bundle exec rails test` が通る
- `bin/rails db:migrate` が通る
- development / test でアプリが起動する

### PR5: `asset-stack-modernization`

目的:
- Rails 7 以降の主要障害になりやすい asset 構成を先に解消する

主な作業:
- `coffee-rails` を削除し、`.coffee` を JS に移行する
- `turbolinks` を `turbo-rails` に置き換える
- `sass-rails` を `dartsass-rails` などへ置き換える
- `uglifier` を削除する
- `spring` を撤去する
- `chromedriver-helper` を撤去し、`selenium-webdriver` 現行系へ寄せる
- `jquery-rails` 依存の残り方を棚卸しする

主なリスク:
- 画面遷移イベントが Turbolinks 依存のまま壊れる
- CoffeeScript を JS 化した際に DOM ready タイミングが変わる
- CSS ビルド方法の変更でレイアウト崩れが出る

完了条件:
- `RAILS_ENV=production bin/rails assets:precompile` が通る
- 一覧、詳細、検索、コメント、いいね、ログイン画面で JS/CSS 崩れがない

### PR6: `ruby-3-1-and-rails-7-0`

目的:
- Rails 7 系へ進むための Ruby 条件を満たし、7.0 に入る

主な作業:
- Ruby を `3.1.x` に更新する
- Rails を `7.0` に更新する
- 互換版の gem へ更新する

更新候補:
- `puma`
- `mysql2`
- `devise`
- `carrierwave`
- `kaminari`
- `haml-rails`
- `selenium-webdriver`

主なリスク:
- keyword argument 仕様差分
- Ruby 3 系での標準ライブラリ依存差分
- devise / session 周りの微妙な挙動差分

完了条件:
- boot, migrate, test, assets が通る
- ログインと投稿機能が壊れていない

### PR7: `rails-7-2-upgrade`

目的:
- Rails 7 系の安定到達点を作る

統合元:
- 旧 PR8 `rails-7-1-upgrade`
- 旧 PR9 `rails-7-2-upgrade`

主な作業:
- Rails を `7.1` 経由で `7.2` へ上げる
- `new_framework_defaults` を個別に確認する
- 不要 initializer を削減する
- production / Active Record / cookies / sessions の差分を吸収する

主なリスク:
- framework defaults を一気に上げた時の挙動差分
- cookie / session / cache の差分
- production 設定や middleware の変更漏れ

完了条件:
- Rails 7.2 で boot, test, assets, migrate が通る
- ここを中間の安定停止点として扱える状態になる

### PR8: `ruby-3-3-or-3-4-and-rails-8-0`

目的:
- Rails 8 系の Ruby 条件を満たし、8.0 に入る

主な作業:
- Ruby を `3.3` か `3.4` に更新する
- Rails を `8.0` に更新する
- 削除 API や deprecated 設定を整理する

主なリスク:
- Rails 8 で削除済み API の利用
- production boot 周りの config 差分
- gem の Ruby 3.3/3.4 対応漏れ

完了条件:
- boot, DB, test, assets が通る
- compatibility shim が最小限になっている

### PR9: `rails-8-1-2-and-final-defaults`

目的:
- 最新安定版へ到達し、最終の defaults に揃える

主な作業:
- Rails を `8.1.2` に更新する
- `config.load_defaults 8.1` に揃える
- 過去互換用の設定や一時的回避策を見直す
- 不要 gem / 不要 initializer / 不要 config を整理する

完了条件:
- `bundle exec rails test` が通る
- `bin/rails db:migrate` が通る
- `RAILS_ENV=production bin/rails assets:precompile` が通る
- ログイン、映画投稿、コメント、いいね、検索、画像アップロードが通る

## 各 PR の共通チェックリスト

- `bundle exec rails test`
- `bin/rails db:migrate`
- `bin/rails db:drop db:create db:migrate` を必要に応じて確認
- `RAILS_ENV=production bin/rails assets:precompile`
- 主要画面の手動確認
  - トップ
  - ログイン / 新規登録
  - 映画投稿
  - 映画詳細
  - コメント
  - いいね
  - 検索
  - マイページ

Rails 6.1 以降の追加チェック:

- `bin/rails zeitwerk:check`

## 優先度の高いリスク

### 1. Asset 周りの老朽化

このアプリの最大リスクは Rails 本体より asset 構成です。

- `coffee-rails`
- `sass-rails`
- `turbolinks`
- `uglifier`
- `jquery-rails`
- Sprockets の `require_tree`

ここを独立 PR にしているのは妥当です。Rails 7 以降へ進む前に整理しないと、失敗時の切り分けが困難になります。

### 2. Ruby 更新に伴う gem 互換性

Ruby 2.6 から Ruby 3.x へ上がる過程で、次の系統は優先的に確認が必要です。

- `mysql2`
- `puma`
- `devise`
- `carrierwave`
- `mini_magick`
- `haml-rails`
- `selenium-webdriver`

### 3. Session / Cookie 周り

現在は Rails 5.2 と current OpenSSL の相性回避設定が development / test に入っています。Rails / Ruby 更新後はこの回避が不要になる可能性がある一方、挙動が変わる可能性もあるため、最後に再評価が必要です。

## 進め方の指針

- 1 PR ごとに review 可能なサイズを保つ
- Rails 本体更新と asset 更新を混ぜすぎない
- `config.load_defaults` は最終段階まで一気に上げない
- Rails 7.2 を最初の大きな安定停止点とする
- Rails 8 系は 7.2 を安定させた後に進める

## 参考

- Rails Upgrading Guide
  - https://guides.rubyonrails.org/upgrading_ruby_on_rails.html
- Rails repository
  - https://github.com/rails/rails
- Rails 8.1.2 gemspec
  - https://raw.githubusercontent.com/rails/rails/v8.1.2/rails.gemspec
- Rails 7.2.3 gemspec
  - https://raw.githubusercontent.com/rails/rails/v7.2.3/rails.gemspec
- Rails 6.1.7.10 gemspec
  - https://raw.githubusercontent.com/rails/rails/v6.1.7.10/rails.gemspec
