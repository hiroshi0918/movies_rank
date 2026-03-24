require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "movie_poster_source prefers attached image" do
    movie = movies(:one)
    movie.update_columns(poster_source_url: "https://example.com/poster.jpg")

    File.open(Rails.root.join("public/apple-touch-icon.png")) do |file|
      movie.image.attach(io: file, filename: "poster.png", content_type: "image/png")
    end

    assert_equal rails_blob_path(movie.image, only_path: true), movie_poster_source(movie)
  end

  test "movie_poster_source falls back to poster source url" do
    movie = movies(:one)
    movie.update_columns(poster_source_url: "https://example.com/poster.jpg")

    assert_equal "https://example.com/poster.jpg", movie_poster_source(movie)
  end

  test "movie_poster_source falls back to placeholder asset" do
    movie = movies(:one)
    movie.update_columns(poster_source_url: nil)

    assert_match(/movie_placeholder/, movie_poster_source(movie))
  end

  test "movie_original_title_text hides identical titles" do
    movie = movies(:one)

    assert_equal "Inception", movie_original_title_text(movie)

    movie.original_title = movie.title
    assert_nil movie_original_title_text(movie)
  end
end
