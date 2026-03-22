require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test 'requires mandatory attributes' do
    movie = Movie.new

    assert_not movie.valid?
    assert_includes movie.errors[:title], "can't be blank"
    assert_includes movie.errors[:director], "can't be blank"
    assert_includes movie.errors[:category], "can't be blank"
    assert_includes movie.errors[:image], "can't be blank"
    assert_includes movie.errors[:user], "can't be blank"
  end

  test 'extracts youtube id from url before validation' do
    movie = movies(:one)
    movie.youtube_url = 'https://www.youtube.com/watch?v=5NV6Rdv1a3I'

    movie.validate
    assert_equal '5NV6Rdv1a3I', movie.youtube_url
    assert_not_includes movie.errors[:youtube_url], 'はYouTubeの動画IDまたはURLを入力してください'
  end
end
