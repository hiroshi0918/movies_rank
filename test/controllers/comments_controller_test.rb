require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @movie = movies(:one)
  end

  test 'guest cannot create comment' do
    post movie_comments_path(@movie), params: { comment: { text: 'new comment' } }
    assert_redirected_to new_user_session_path
  end

  test 'signed in user can create comment' do
    sign_in @user
    assert_difference('Comment.count', 1) do
      post movie_comments_path(@movie), params: { comment: { text: 'new comment' } }
    end
    assert_redirected_to movie_path(@movie)
  end

  test 'signed in user can create comment via json' do
    sign_in @user
    assert_difference('Comment.count', 1) do
      post movie_comments_path(@movie, format: :json), params: { comment: { text: 'json comment' } }
    end
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'json comment', json_response['text']
    assert_equal @user.nickname, json_response['user_name']
  end

  test 'invalid comment returns unprocessable entity' do
    sign_in @user
    assert_no_difference('Comment.count') do
      post movie_comments_path(@movie, format: :json), params: { comment: { text: '' } }
    end
    assert_response :unprocessable_entity
  end
end
