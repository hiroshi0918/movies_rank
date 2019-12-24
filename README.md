## usersテーブル
|Column|Type|Options|
|------|----|-------|
|email|string|null: false, unique: true|
|password|string|null: false|
|username|string|null: false, unique: true|
### Association
- has_many :movies
- has_many :comments
- has_many :likes

## moviesテーブル
|Column|Type|Options|
|------|----|-------|
|title|string|null: false,unique: true|
|derector|string|null: false|
|detail|text||
|category|string|null:false|
|image|text|null:false|
### Association
- belongs_to :user
- has_many :comments
- has_many :movies_tags
- has_many  :tags,  through:  :movies_tags
- has_many :likes

## tagsテーブル
|Column|Type|Options|
|------|----|-------|
|name|string|null: false|
### Association
- has_many :movies_tags
- has_many  :movies,  through:  :movies_tags

## movies_tagsテーブル
|Column|Type|Options|
|------|----|-------|
|post_id|integer|null: false, foreign_key: true|
|tag_id|integer|null: false, foreign_key: true|
### Association
- belongs_to :movie
- belongs_to :tag

## commentsテーブル
|Column|Type|Options|
|------|----|-------|
|text|text|null: false|
|user_id|integer|null: false, foreign_key: true|
|group_id|integer|null: false, foreign_key: true|
### Association
- belongs_to :movie
- belongs_to :user

## likesテーブル
|Column|Type|Options|
|------|----|-------|
|user_id|integer|null:false, foreign_key: true|
|movies_id|integer|null:false, foreign_key: true|
### Association
- belongs_to :user
- belongs_to :movie