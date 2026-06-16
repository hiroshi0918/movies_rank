class Movie < ApplicationRecord
  # 画像未設定時のフォールバック。外部サービス(via.placeholder.com)は停止済みのため、
  # 外部依存ゼロのインラインSVG(data URI)を使う。
  PLACEHOLDER_SVG = <<~SVG.squish.freeze
    <svg xmlns='http://www.w3.org/2000/svg' width='300' height='450' viewBox='0 0 300 450'>
      <rect width='300' height='450' fill='#2a2a2a'/>
      <text x='150' y='225' fill='#8a8a8a' font-family='sans-serif' font-size='22'
            text-anchor='middle' dominant-baseline='middle'>No Poster</text>
    </svg>
  SVG
  PLACEHOLDER_IMAGE = "data:image/svg+xml,#{CGI.escape(PLACEHOLDER_SVG)}".freeze

  has_one_attached :image

  def image_url(*args)
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    elsif poster_source_url.present? && poster_source_url.to_s.start_with?('http')
      poster_source_url
    else
      PLACEHOLDER_IMAGE
    end
  end

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :title, :director, :category, :user, presence: true
  validates :youtube_url, format: { with: /\A[a-zA-Z0-9_-]{11}\z/, message: "はYouTubeの動画IDまたはURLを入力してください" }, allow_blank: true
  # ActiveStorage添付(image)か、外部URL文字列(poster_source_url)のどちらかがあればOK。
  # 文字列カラムにURLを持つシード/取込済み映画でも、画像を再アップロードせず編集できるようにする。
  validate :poster_present

  before_validation :normalize_youtube_url

  def self.search(search)
    # 空キーワードでは全件を返さない(全件ロード/意図しない一覧化を避ける)。
    return none unless search.present?

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

    errors.add(:image, :blank)
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
