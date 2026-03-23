require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @movie = movies(:one)
  end

  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get rank" do
    get rank_movies_url
    assert_response :success
  end

  test "should search movies" do
    get search_movies_url, params: { keyword: 'Inception' }
    assert_response :success
    assert_select '.grid-card__title', text: 'Inception'
  end

  test "should search movies via json" do
    get search_movies_url(format: :json), params: { keyword: 'Inception' }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert_equal @movie.title, json_response.first['title']
  end

  test "should show movie" do
    get movie_url(@movie)
    assert_response :success
  end

  test "guest should not get new" do
    get new_movie_url
    assert_redirected_to new_user_session_url
  end

  test "authenticated user should get new" do
    sign_in @user
    get new_movie_url
    assert_response :success
  end
end
