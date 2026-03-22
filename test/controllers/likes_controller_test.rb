require 'test_helper'

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
  end

  test 'guest cannot like a movie' do
    post movie_like_path(@movie)

    assert_redirected_to new_user_session_path
  end

  test 'signed in user can like a movie' do
    sign_in users(:two)

    assert_difference('Like.count', 1) do
      post movie_like_path(@movie)
    end

    assert_redirected_to movie_path(@movie)
  end

  test 'signed in user can unlike a movie' do
    sign_in users(:one)

    assert_difference('Like.count', -1) do
      delete movie_like_path(@movie)
    end

    assert_redirected_to movie_path(@movie)
  end
end
