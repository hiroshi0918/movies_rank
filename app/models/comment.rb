class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  
  validates :text, presence: true
end
