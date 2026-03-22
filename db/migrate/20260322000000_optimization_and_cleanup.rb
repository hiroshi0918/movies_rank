class OptimizationAndCleanup < ActiveRecord::Migration[5.2]
  def up
    cleanup_orphan_records
    deduplicate_likes

    align_reference_column_types

    add_index :comments, :user_id unless index_exists?(:comments, :user_id)
    add_index :comments, :movie_id unless index_exists?(:comments, :movie_id)
    add_index :movies, :user_id unless index_exists?(:movies, :user_id)
    add_index :likes, [:movie_id, :user_id], unique: true unless index_exists?(:likes, [:movie_id, :user_id], unique: true)

    unless column_exists?(:movies, :likes_count)
      add_column :movies, :likes_count, :integer, default: 0, null: false
    end

    change_column_null :comments, :user_id, false
    change_column_null :comments, :movie_id, false
    change_column_null :comments, :text, false
    change_column_null :movies, :user_id, false
    change_column_null :likes, :movie_id, false
    change_column_null :likes, :user_id, false

    add_foreign_key :comments, :users unless foreign_key_exists?(:comments, :users)
    add_foreign_key :comments, :movies unless foreign_key_exists?(:comments, :movies)
    add_foreign_key :movies, :users unless foreign_key_exists?(:movies, :users)

    backfill_likes_count

    drop_table :views if table_exists?(:views)
  end

  def down
    create_table :views do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["email"], name: "index_views_on_email", unique: true
      t.index ["reset_password_token"], name: "index_views_on_reset_password_token", unique: true
    end unless table_exists?(:views)

    remove_foreign_key :movies, :users if foreign_key_exists?(:movies, :users)
    remove_foreign_key :comments, :movies if foreign_key_exists?(:comments, :movies)
    remove_foreign_key :comments, :users if foreign_key_exists?(:comments, :users)

    revert_reference_column_types

    change_column_null :likes, :user_id, true
    change_column_null :likes, :movie_id, true
    change_column_null :movies, :user_id, true
    change_column_null :comments, :text, true
    change_column_null :comments, :movie_id, true
    change_column_null :comments, :user_id, true

    remove_column :movies, :likes_count if column_exists?(:movies, :likes_count)
    remove_index :likes, column: [:movie_id, :user_id] if index_exists?(:likes, [:movie_id, :user_id])
    remove_index :movies, :user_id if index_exists?(:movies, :user_id)
    remove_index :comments, :movie_id if index_exists?(:comments, :movie_id)
    remove_index :comments, :user_id if index_exists?(:comments, :user_id)
  end

  private

  def cleanup_orphan_records
    execute <<~SQL
      DELETE movies FROM movies
      LEFT JOIN users ON movies.user_id = users.id
      WHERE movies.user_id IS NULL
         OR users.id IS NULL
    SQL

    execute <<~SQL
      DELETE comments FROM comments
      LEFT JOIN users ON comments.user_id = users.id
      LEFT JOIN movies ON comments.movie_id = movies.id
      WHERE comments.user_id IS NULL
         OR comments.movie_id IS NULL
         OR comments.text IS NULL
         OR users.id IS NULL
         OR movies.id IS NULL
    SQL

    execute <<~SQL
      DELETE likes FROM likes
      LEFT JOIN users ON likes.user_id = users.id
      LEFT JOIN movies ON likes.movie_id = movies.id
      WHERE likes.user_id IS NULL
         OR likes.movie_id IS NULL
         OR users.id IS NULL
         OR movies.id IS NULL
    SQL
  end

  def deduplicate_likes
    execute <<~SQL
      DELETE duplicate_likes FROM likes AS duplicate_likes
      INNER JOIN likes AS original_likes
              ON duplicate_likes.user_id = original_likes.user_id
             AND duplicate_likes.movie_id = original_likes.movie_id
             AND duplicate_likes.id > original_likes.id
    SQL
  end

  def align_reference_column_types
    ensure_bigint_column :comments, :user_id
    ensure_bigint_column :comments, :movie_id
    ensure_bigint_column :movies, :user_id
  end

  def revert_reference_column_types
    ensure_integer_column :movies, :user_id
    ensure_integer_column :comments, :movie_id
    ensure_integer_column :comments, :user_id
  end

  def ensure_bigint_column(table_name, column_name)
    return unless column_exists?(table_name, column_name)
    return if column_type(table_name, column_name) == :bigint

    change_column table_name, column_name, :bigint
  end

  def ensure_integer_column(table_name, column_name)
    return unless column_exists?(table_name, column_name)
    return if column_type(table_name, column_name) == :integer

    change_column table_name, column_name, :integer
  end

  def column_type(table_name, column_name)
    connection.columns(table_name).find { |column| column.name == column_name.to_s }&.type
  end

  def backfill_likes_count
    execute <<~SQL
      UPDATE movies
      LEFT JOIN (
        SELECT movie_id, COUNT(*) AS likes_total
        FROM likes
        GROUP BY movie_id
      ) AS likes_summary ON likes_summary.movie_id = movies.id
      SET movies.likes_count = COALESCE(likes_summary.likes_total, 0)
    SQL
  end
end
