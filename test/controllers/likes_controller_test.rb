require 'test_helper'

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @movie = movies(:two) # users(:one) has NOT liked movies(:two) in fixtures
  end

  test 'guest cannot like' do
    post movie_like_path(@movie)
    assert_redirected_to new_user_session_path
  end

  test 'signed in user can like and unlike a movie' do
    sign_in @user
    
    # Like
    assert_difference('Like.count', 1) do
      post movie_like_path(@movie)
    end
    assert_redirected_to movie_path(@movie)
    assert @user.already_liked?(@movie)
    
    # Unlike
    assert_difference('Like.count', -1) do
      delete movie_like_path(@movie)
    end
    assert_redirected_to movie_path(@movie)
    assert_not @user.already_liked?(@movie)
  end
end
