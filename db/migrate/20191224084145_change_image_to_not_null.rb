class ChangeImageToNotNull < ActiveRecord::Migration[5.2]
  def change
    def up
      change_column :movies, :image,:string, null: true
    end
  
    def down
      change_column :movies, :image,:string, null: false
    end
  end
end
