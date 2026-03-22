class Like < ApplicationRecord
  belongs_to :movie, counter_cache: :likes_count
  belongs_to :user
  validates :movie_id, uniqueness: { scope: :user_id }
end
