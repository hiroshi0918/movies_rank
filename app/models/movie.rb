class Movie < ApplicationRecord
  mount_uploader :image, ImageUploader
  
  belongs_to :user
  has_many :comments
  has_many :likes
  has_many :liked_users, through: :likes, source: :user

  def self.search(search)
    return Movie.all unless search
    Movie.where('title LIKE(?)', "%#{search}%")
  end
end
