class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :movies, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_movies, through: :likes, source: :movie

  # nicknameは表示名・プロフィール(users#show)で必須。空だと nil[0] 等で500になるため必須化する。
  validates :nickname, presence: true, length: { maximum: 50 }

  def already_liked?(movie)
    likes.exists?(movie_id: movie.id)
  end
end
