class Like < ApplicationRecord
  belongs_to :movie, counter_cache: :likes_count
  belongs_to :user
  validates_uniqueness_of :movie_id, scope: :user_id
end
