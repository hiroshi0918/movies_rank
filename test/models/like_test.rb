require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  test 'does not allow duplicate likes for the same movie and user' do
    duplicate_like = Like.new(movie: movies(:one), user: users(:one))

    assert_not duplicate_like.valid?
    assert_includes duplicate_like.errors[:movie_id], 'has already been taken'
  end
end
