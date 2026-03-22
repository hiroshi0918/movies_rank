require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
  end

  test 'guest is redirected from new movie page' do
    get new_movie_path

    assert_redirected_to new_user_session_path
  end

  test 'non owner cannot access edit page' do
    sign_in users(:two)

    get edit_movie_path(@movie)

    assert_redirected_to movie_path(@movie)
    assert_equal '自分の投稿のみ編集できます', flash[:alert]
  end

  test 'owner can update own movie' do
    sign_in users(:one)
    image = Rack::Test::UploadedFile.new(
      Rails.root.join('public/apple-touch-icon.png'),
      'image/png'
    )

    patch movie_path(@movie), params: {
      movie: {
        title: 'Updated Title',
        director: @movie.director,
        category: @movie.category,
        image: image,
        detail: @movie.detail,
        youtube_url: @movie.youtube_url
      }
    }

    assert_redirected_to movie_path(@movie)
    assert_equal 'Updated Title', @movie.reload.title
  end
end
