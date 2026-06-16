require "application_system_test_case"

class MoviesTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @movie = movies(:one)
  end

  test "visiting the index" do
    visit root_url

    assert_selector "a.title", text: /MoviesRank/i
    # Netflix風ホーム: 横スクロール行とカード。死リンク・偽データが無いこと。
    assert_selector ".movie-card", minimum: 1
    assert_no_text "98% マッチ"
  end

  test "searching for a movie by original title" do
    visit search_movies_path(keyword: "Inception")

    assert_selector ".grid-card__title", text: /インセプション/i, visible: :all
  end

  test "viewing movie details and trailer" do
    visit new_user_session_path
    fill_in "メールアドレス", with: @user.email
    fill_in "パスワード", with: "password123"
    click_button "ログイン"

    assert_text "Signed in successfully."

    visit movie_path(@movie)

    assert_selector ".show-details__title", text: @movie.title
    assert_text "原題: #{@movie.original_title}"
    assert_selector ".show-details__video"
    assert_selector "iframe[title='予告編']"
    assert_link "YouTubeで開く"
  end
end
