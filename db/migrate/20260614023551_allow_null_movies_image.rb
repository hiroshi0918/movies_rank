class AllowNullMoviesImage < ActiveRecord::Migration[8.1]
  # 画像はActiveStorage添付(has_one_attached :image)で管理するようになったため、
  # レガシーの文字列カラム movies.image は任意(null許可)にする。
  # NOT NULL のままだとフォーム経由の新規投稿(添付のみ・文字列カラム未設定)が
  # NotNullViolation で失敗していた。値の有無は Movie#image_must_be_present で担保する。
  def up
    change_column_null :movies, :image, true
  end

  def down
    # 既存のnull行を空文字で埋めてからNOT NULLに戻す
    execute "UPDATE movies SET image = '' WHERE image IS NULL"
    change_column_null :movies, :image, false
  end
end
