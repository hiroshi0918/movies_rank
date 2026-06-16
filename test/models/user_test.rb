require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'already_liked? returns true if user liked the movie' do
    user = users(:one)
    movie = movies(:one)
    assert user.already_liked?(movie)
  end

  test 'already_liked? returns false if user has not liked the movie' do
    user = users(:one)
    movie = movies(:two)
    assert_not user.already_liked?(movie)
  end
  
  test 'destroying user destroys associated dependencies' do
    user = users(:one)
    assert_difference('User.count', -1) do
      user.destroy
    end
  end

  test 'requires nickname' do
    user = User.new(email: 'x@example.com', password: 'password123', nickname: '')
    assert_not user.valid?
    assert_includes user.errors[:nickname], "can't be blank"
  end

  test 'destroying user cascades to its movies' do
    user = users(:one)
    movies_count = user.movies.count
    assert movies_count.positive?
    assert_difference('Movie.count', -movies_count) do
      user.destroy
    end
  end
end
