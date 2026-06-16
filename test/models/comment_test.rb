require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test 'requires text' do
    comment = Comment.new(user: users(:one), movie: movies(:one), text: '')
    assert_not comment.valid?
    assert_includes comment.errors[:text], "can't be blank"
  end

  test 'can store 4-byte characters (emoji) after utf8mb4 migration' do
    # utf8mb3 では絵文字保存時に例外/欠落が起きていた。utf8mb4 で保存・取得できることを担保する。
    comment = Comment.create!(user: users(:one), movie: movies(:one), text: '最高でした😀🎬')
    assert_equal '最高でした😀🎬', comment.reload.text
  end
end
