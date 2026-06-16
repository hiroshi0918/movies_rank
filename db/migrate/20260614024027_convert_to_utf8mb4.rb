class ConvertToUtf8mb4 < ActiveRecord::Migration[8.1]
  # utf8mb3 では4バイト文字(絵文字など)を保存できず、コメントやタイトルの投稿が
  # 失敗・欠落していた。DBと全テーブルを utf8mb4 に変換する。
  TABLES = %w[
    users movies comments likes
    active_storage_blobs active_storage_attachments active_storage_variant_records
  ].freeze

  def up
    convert_all("utf8mb4", "utf8mb4_unicode_ci")
  end

  def down
    convert_all("utf8mb3", "utf8mb3_general_ci")
  end

  private

  def convert_all(charset, collation)
    database = ActiveRecord::Base.connection.current_database
    execute "ALTER DATABASE `#{database}` CHARACTER SET #{charset} COLLATE #{collation}"
    TABLES.each do |table|
      next unless table_exists?(table)

      execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
    end
  end
end
