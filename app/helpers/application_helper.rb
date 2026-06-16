module ApplicationHelper
  def movie_poster_source(movie)
    return rails_blob_path(movie.image, only_path: true) if movie.image.attached?

    image_value = movie.poster_source_url.to_s
    return image_value if image_value.start_with?("http://", "https://")

    asset_path("movie_placeholder.svg")
  end

  def movie_poster_tag(movie, class_name:, alt: nil)
    fallback_src = asset_path("movie_placeholder.svg")

    image_tag(
      movie_poster_source(movie),
      alt: alt || movie.title,
      class: class_name,
      loading: "lazy",
      onerror: "this.onerror=null;this.src='#{fallback_src}';this.classList.add('is-fallback');"
    )
  end

  def movie_likes_text(movie)
    "#{movie.likes_total}件のいいね"
  end

  def movie_original_title_text(movie)
    return if movie.original_title.blank?
    return if movie.original_title == movie.title

    movie.original_title
  end
end
