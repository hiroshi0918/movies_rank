require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @movie = movies(:one)
    @movie_without_trailer = movies(:three)
  end

  test "should get index" do
    get root_url

    assert_response :success
    assert_select 'h1', '新着の映画'
    assert_select 'article.movie-card', minimum: 1
    assert_select 'a[href="#"]', count: 0
    assert_select '*', text: /今日のTOP10（日本）/, count: 0
    assert_select '*', text: /視聴中コンテンツ/, count: 0
    assert_select '*', text: /98% マッチ/, count: 0
  end

  test "index paginates movies" do
    rows = 30.times.map do |i|
      {
        title: "映画 #{i}",
        original_title: "Movie #{i}",
        director: "Director #{i}",
        category: "Drama",
        detail: "detail #{i}",
        poster_source_url: "https://example.com/poster-#{i}.jpg",
        user_id: @user.id,
        created_at: Time.current + i.minutes,
        updated_at: Time.current + i.minutes
      }
    end
    Movie.insert_all!(rows)

    get root_url

    assert_response :success
    assert_select 'article.movie-card', 25
  end

  test "should get rank" do
    @movie.update_columns(likes_count: 5)
    movies(:two).update_columns(likes_count: 3)

    get rank_movies_url

    assert_response :success
    assert_select 'h1', '人気ランキング'
    assert_select '.movie-card__rank', text: '1'
  end

  test "should search movies" do
    get search_movies_url, params: { keyword: 'Inception' }

    assert_response :success
    assert_select '.movie-card__title', text: 'インセプション'
  end

  test "should search movies via json" do
    get search_movies_url(format: :json), params: { keyword: 'Inception' }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert_equal @movie.title, json_response.first['title']
    assert_equal @movie.original_title, json_response.first['original_title']
    assert_match(/movie_placeholder/, json_response.first['image'])
  end

  test "should show movie with trailer" do
    get movie_url(@movie)

    assert_response :success
    assert_select 'h1', text: @movie.title
    assert_select '.detail-body__original-title', text: /#{Regexp.escape(@movie.original_title)}/
    assert_select '.detail-video-card', 1
    assert_select 'iframe[title="予告編"]', 1
    assert_select 'a', text: 'YouTubeで開く'
  end

  test "should hide trailer section when youtube is absent" do
    get movie_url(@movie_without_trailer)

    assert_response :success
    assert_select '.detail-video-card', 0
    assert_select 'iframe[title="予告編"]', 0
    assert_select 'a', text: 'YouTubeで開く', count: 0
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
