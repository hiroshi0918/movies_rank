class ChangeImageTitleToMovies < ActiveRecord::Migration[5.2]
  def change
    change_column :movies, :image, :string
  end
end
