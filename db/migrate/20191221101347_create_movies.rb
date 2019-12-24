class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies do |t|
      t.string :title, null: false, unique: true
      t.string :director, null: false
      t.string :category, null: false
      t.text :image, null: false, unique: true
      t.timestamps
    end
  end
end
