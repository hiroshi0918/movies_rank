# MoviesRank

MoviesRankは、気に入った映画を投稿して共有できるRailsアプリです。  
映画の一覧表示、検索、いいね数によるランキング、レビューコメントなどを通じて、ユーザー同士で映画を見つけやすくすることを目的としています。

## できること

- 映画の投稿
  - タイトル、監督名、ジャンル、あらすじ、画像、YouTube URLを登録できます。
- 映画の一覧表示
  - 投稿された映画をトップページで一覧表示します。
- 映画検索
  - タイトル名で映画を検索できます。
- いいね機能
  - 気に入った映画にいいねできます。
- ランキング表示
  - いいね数の多い映画をランキング形式で確認できます。
- コメント機能
  - 映画詳細ページでレビューや感想を投稿できます。
- マイページ
  - ユーザーごとの投稿一覧と、いいねした映画を確認できます。

## 画面イメージ

- トップページ
  - 投稿された映画がカード形式で並びます。
- 映画詳細ページ
  - 映画情報、あらすじ、YouTube埋め込み動画、コメント、いいね操作を確認できます。
- ランキングページ
  - いいね数の多い映画を上位から表示します。
- マイページ
  - 自分の投稿一覧と、いいねした映画を表示します。

## 使用技術

- Ruby 2.5.1
- Rails 5.2.4.1
- MySQL
- Haml
- SCSS
- JavaScript / jQuery
- Devise
- CarrierWave
- MiniMagick
- Kaminari

## 主なモデル

### User

- 映画の投稿
- コメント投稿
- いいね

### Movie

- 映画情報の登録
- コメントの紐付け
- いいねの集計
- タイトル検索
- いいねランキング生成

### Comment

- ユーザーが映画に対して感想を投稿

### Like

- ユーザーごとのいいね管理
- 同じ映画への重複いいねを防止

## セットアップ

### 前提

- Ruby 2.5.1
- Bundler
- MySQL
- ImageMagick

### インストール手順

1. リポジトリを取得します。

```bash
git clone <repository-url>
cd movies_rank
```

2. gemをインストールします。

```bash
bundle install
```

3. データベース設定を行います。  
`config/database.yml` を自分のMySQL環境に合わせて編集してください。

4. データベースを作成してマイグレーションを実行します。

```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

5. アプリを起動します。

```bash
bundle exec rails s
```

6. ブラウザで以下にアクセスします。

```text
http://localhost:3000
```

## 使い方

1. 新規登録またはログインします。
2. 「新規投稿」から映画情報を登録します。
3. トップページで投稿された映画を確認します。
4. 検索フォームから見たい映画を探します。
5. 映画詳細ページでいいねやコメントを行います。
6. ランキングページで人気作品を確認します。

## ルーティング概要

- `/`
  - 映画一覧
- `/movies/new`
  - 新規映画投稿
- `/movies/:id`
  - 映画詳細
- `/movies/search`
  - 映画検索
- `/movies/rank`
  - ランキング
- `/users/:id`
  - マイページ

## データ構成

### users

| Column | Type |
| ------ | ---- |
| email | string |
| encrypted_password | string |
| nickname | string |

### movies

| Column | Type |
| ------ | ---- |
| title | string |
| director | string |
| category | string |
| image | string |
| detail | text |
| youtube_url | string |
| user_id | integer |

### comments

| Column | Type |
| ------ | ---- |
| user_id | integer |
| movie_id | integer |
| text | text |

### likes

| Column | Type |
| ------ | ---- |
| user_id | bigint |
| movie_id | bigint |

## 補足

- 認証にはDeviseを利用しています。
- 画像アップロードにはCarrierWaveを利用しています。
- ランキングはいいね数をもとに算出しています。
