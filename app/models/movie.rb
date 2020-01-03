class Movie < ApplicationRecord
  mount_uploader :image, ImageUploader
  
  belongs_to :user
  has_many :comments
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  def self.search(search)
    return Movie.all unless search
    Movie.where('title LIKE(?)', "%#{search}%")
  end

  def self.create_all_ranks
    Movie.find(Like.group(:movie_id).order('count(movie_id) desc').limit(10).pluck(:movie_id))
  end
end
