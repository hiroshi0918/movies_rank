class Movie < ApplicationRecord
  mount_uploader :image, ImageUploader

  def image_url(*args)
    if self[:image].present? && self[:image].to_s.start_with?('http')
      self[:image]
    elsif self[:image].present?
      super
    else
      "https://via.placeholder.com/300x450/333333/ffffff?text=No+Poster"
    end
  end
  
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :title, :director, :category, :image, :user, presence: true
  validates :youtube_url, format: { with: /\A[a-zA-Z0-9_-]{11}\z/, message: "はYouTubeの動画IDまたはURLを入力してください" }, allow_blank: true

  before_validation :normalize_youtube_url

  def self.search(search)
    return all unless search.present?

    where('title LIKE ?', "%#{sanitize_sql_like(search)}%")
  end

  def self.create_all_ranks
    where.not(likes_count: 0).order(likes_count: :desc).limit(10)
  end

  def likes_total
    likes_count.to_i
  end

  private

  def normalize_youtube_url
    return if youtube_url.blank?

    self.youtube_url = extract_video_id(youtube_url)
  end

  def extract_video_id(value)
    return value if value.match?(/\A[a-zA-Z0-9_-]{11}\z/)

    matched = value.match(%r{(?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/|shorts/))([a-zA-Z0-9_-]{11})})
    matched ? matched[1] : value
  end
end
