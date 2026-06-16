class AddOriginalTitleAndRenameMovieImage < ActiveRecord::Migration[8.1]
  def change
    rename_column :movies, :image, :poster_source_url
    add_column :movies, :original_title, :string
    change_column_null :movies, :poster_source_url, true
  end
end
