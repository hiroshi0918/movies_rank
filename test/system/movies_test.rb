require "application_system_test_case"

class MoviesTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @movie = movies(:one)
  end

  test "visiting the index" do
    visit root_url

    assert_selector "a.title", text: /MoviesRank/i
    assert_selector "h1", text: "新着の映画"
    assert_no_text "今日のTOP10（日本）"
    assert_no_text "視聴中コンテンツ"
  end

  test "searching for a movie" do
    visit root_url
    fill_in "keyword", with: "Inception"
    click_button "検索"

    assert_current_path search_movies_path(keyword: "Inception")
    assert_selector ".movie-card__title", text: /Inception/i, visible: :all
  end

  test "viewing movie details and trailer" do
    visit new_user_session_path
    fill_in "メールアドレス", with: @user.email
    fill_in "パスワード", with: "password123"
    click_button "ログイン"

    assert_text "Signed in successfully."

    visit movie_path(@movie)

    assert_selector "h1", text: @movie.title
    assert_selector "iframe[title='予告編']"
    assert_link "YouTubeで開く"
  end
end
