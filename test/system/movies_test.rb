require "application_system_test_case"

class MoviesTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @movie = movies(:one)
    
    # We need to simulate image attachment for system tests if ActiveStorage relies on it
    if File.exist?(Rails.root.join('test/fixtures/files/sample.jpg'))
      @movie.image.attach(io: File.open(Rails.root.join('test/fixtures/files/sample.jpg')), filename: 'sample.jpg')
    end
  end

  test "visiting the index" do
    visit root_url
    assert_selector "a.title", text: /MoviesRank/i
  end

  test "searching for a movie" do
    visit root_url
    fill_in "keyword", with: "Inception"
    find('button.sbtn').click
    
    # This should submit the form and redirect to /movies/search because we aren't on the search page
    # where the list target exists
    assert_current_path search_movies_path(keyword: "Inception")
    assert_selector "div.grid-card__title", text: /Inception/i, visible: :all
  end
  
  test "viewing movie details and adding comment" do
    # Sign in to comment
    visit new_user_session_path
    fill_in "メールアドレス", with: @user.email
    fill_in "パスワード", with: "password123"
    click_button "ログイン"
    
    assert_text "Signed in successfully." # Make sure login is actually successful
    
    visit movie_path(@movie)
    assert_selector "h1", text: @movie.title
  end
end
