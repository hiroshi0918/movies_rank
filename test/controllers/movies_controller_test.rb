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
    # Netflix風ホーム: 横スクロール行＋カード。死リンク・偽データが無いこと。
    assert_select '.movie-card', minimum: 1
    assert_select 'a[href="#"]', count: 0
    assert_select '*', text: /98% マッチ/, count: 0
  end

  test "should get rank" do
    @movie.update_columns(likes_count: 5)
    movies(:two).update_columns(likes_count: 3)

    get rank_movies_url

    assert_response :success
    assert_select '.grid-page__title', text: /ランキング/
    assert_select '.rank-badge', text: '1'
  end

  test "should get catalog" do
    get catalog_movies_url
    assert_response :success
    assert_select '.grid-card'
  end

  test "catalog filters by category" do
    get catalog_movies_url, params: { category: movies(:one).category }
    assert_response :success
    assert_select '.grid-card__title', text: movies(:one).title
  end

  test "catalog sorts by popular without error" do
    get catalog_movies_url, params: { sort: 'popular' }
    assert_response :success
  end

  test "catalog ignores invalid sort param" do
    get catalog_movies_url, params: { sort: 'bogus' }
    assert_response :success
  end

  test "should search movies by original title" do
    get search_movies_url, params: { keyword: 'Inception' }

    assert_response :success
    assert_select '.grid-card__title', text: 'インセプション'
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
    assert_select '.show-details__title', text: @movie.title
    assert_select '.show-details__original-title', text: /#{Regexp.escape(@movie.original_title)}/
    assert_select '.show-details__video', 1
    assert_select 'iframe[title="予告編"]', 1
    assert_select 'a', text: 'YouTubeで開く'
  end

  test "should hide trailer section when youtube is absent" do
    get movie_url(@movie_without_trailer)

    assert_response :success
    assert_select '.show-details__video', 0
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

  test "owner can create movie with uploaded image" do
    sign_in @user
    image = fixture_file_upload(Rails.root.join('public/apple-touch-icon.png'), 'image/png')
    assert_difference('Movie.count', 1) do
      post movies_url, params: { movie: {
        title: '新作', original_title: 'New Movie', director: '監督', category: 'アクション', detail: 'あらすじ', image: image
      } }
    end
    assert_redirected_to root_path
  end

  test "owner can update title without re-uploading image" do
    # 外部URL文字列(poster_source_url)を持つだけ(添付なし)の映画でも、画像を再アップロードせず編集できる
    sign_in @user
    patch movie_url(@movie), params: { movie: { title: '改題' } }
    assert_redirected_to movie_path(@movie.id)
    assert_equal '改題', @movie.reload.title
  end

  test "non-owner cannot update movie" do
    sign_in users(:two)
    original = @movie.title
    patch movie_url(@movie), params: { movie: { title: '乗っ取り' } }
    assert_redirected_to movie_path(@movie)
    assert_equal original, @movie.reload.title
  end

  test "guest cannot update movie" do
    patch movie_url(@movie), params: { movie: { title: 'x' } }
    assert_redirected_to new_user_session_url
  end

  test "owner can destroy movie" do
    sign_in @user
    assert_difference('Movie.count', -1) do
      delete movie_url(@movie)
    end
    assert_redirected_to root_path
  end

  test "non-owner cannot destroy movie" do
    sign_in users(:two)
    assert_no_difference('Movie.count') do
      delete movie_url(@movie)
    end
    assert_redirected_to movie_path(@movie)
  end
end
