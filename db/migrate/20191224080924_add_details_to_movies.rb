class AddDetailsToMovies < ActiveRecord::Migration[5.2]
  def change
    add_column :movies, :detail, :text
  end
end
