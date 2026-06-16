require "test_helper"
require "stringio"

class MovieCatalogImporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @entry = {
      title: "インセプション",
      original_title: "Inception",
      director: "Christopher Nolan",
      category: "SF",
      detail: "Dream within a dream.",
      poster_source_url: "https://example.com/poster.jpg",
      youtube_url: "GfnyDtiXfns"
    }
  end

  test "import updates existing movie and is idempotent" do
    movie = movies(:one)
    movie.update_columns(title: "Inception", original_title: nil, poster_source_url: nil)

    importer = MovieCatalogImporter.new(
      entries: [@entry],
      users: [@user],
      poster_fetcher: method(:fake_poster_fetcher)
    )

    assert_no_difference("Movie.count") do
      assert_difference("ActiveStorage::Attachment.count", 1) do
        importer.import!
      end
    end

    movie.reload
    assert_equal "インセプション", movie.title
    assert_equal "Inception", movie.original_title
    assert_equal "https://example.com/poster.jpg", movie.poster_source_url
    assert_equal "GfnyDtiXfns", movie.youtube_url
    assert movie.image.attached?

    assert_no_difference("Movie.count") do
      assert_no_difference("ActiveStorage::Attachment.count") do
        importer.import!
      end
    end
  end

  test "import raises when poster fetch fails" do
    movie = movies(:one)
    movie.update_columns(title: "Inception", original_title: nil, poster_source_url: nil)

    importer = MovieCatalogImporter.new(
      entries: [@entry],
      users: [@user],
      poster_fetcher: ->(_url, filename:) { raise "poster fetch failed for #{filename}" }
    )

    error = assert_raises(RuntimeError) { importer.import! }
    assert_match(/poster fetch failed/, error.message)

    movie.reload
    assert_nil movie.original_title
    assert_not movie.image.attached?
  end

  private

  def fake_poster_fetcher(_url, filename:)
    {
      io: StringIO.new("fake image data"),
      filename: filename,
      content_type: "image/png"
    }
  end
end
