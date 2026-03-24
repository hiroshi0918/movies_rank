class Movie < ApplicationRecord
  has_one_attached :image

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :title, :director, :category, :user, presence: true
  validates :youtube_url, format: { with: /\A[a-zA-Z0-9_-]{11}\z/, message: "はYouTubeの動画IDまたはURLを入力してください" }, allow_blank: true

  before_validation :normalize_youtube_url
  validate :poster_present

  def self.search(search)
    return all unless search.present?

    keyword = "%#{sanitize_sql_like(search)}%"
    where("title LIKE :keyword OR original_title LIKE :keyword", keyword: keyword)
  end

  def self.create_all_ranks
    where.not(likes_count: 0).order(likes_count: :desc).limit(10)
  end

  def likes_total
    likes_count.to_i
  end

  private

  def poster_present
    return if image.attached? || poster_source_url.present?

    errors.add(:image, "を設定してください")
  end

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
