require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
  end

  test 'guest cannot create comment' do
    post movie_comments_path(@movie), params: { comment: { text: 'new comment' } }

    assert_redirected_to new_user_session_path
  end

  test 'signed in user can create comment' do
    sign_in users(:one)

    assert_difference('Comment.count', 1) do
      post movie_comments_path(@movie), params: { comment: { text: 'new comment' } }
    end

    assert_redirected_to movie_path(@movie)
  end

  test 'invalid comment returns unprocessable entity' do
    sign_in users(:one)

    assert_no_difference('Comment.count') do
      post movie_comments_path(@movie), params: { comment: { text: '' } }
    end

    assert_response :unprocessable_entity
  end
end
