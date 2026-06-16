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

  test "owner can create movie with uploaded image" do
    sign_in @user
    image = fixture_file_upload(Rails.root.join('public/apple-touch-icon.png'), 'image/png')
    assert_difference('Movie.count', 1) do
      post movies_url, params: { movie: {
        title: '新作', director: '監督', category: 'アクション', detail: 'あらすじ', image: image
      } }
    end
    assert_redirected_to root_path
  end

  test "owner can update title without re-uploading image" do
    # 文字列カラムに画像URLを持つだけ(添付なし)の映画でも、画像を再アップロードせず編集できる
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
