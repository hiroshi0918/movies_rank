require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  test 'requires mandatory attributes' do
    movie = Movie.new

    assert_not movie.valid?
    assert_includes movie.errors[:title], "can't be blank"
    assert_includes movie.errors[:director], "can't be blank"
    assert_includes movie.errors[:category], "can't be blank"
    assert_includes movie.errors[:user], "can't be blank"
  end

  test 'extracts youtube id from url before validation' do
    movie = movies(:one)
    movie.youtube_url = 'https://www.youtube.com/watch?v=5NV6Rdv1a3I'

    movie.validate
    assert_equal '5NV6Rdv1a3I', movie.youtube_url
    assert_not_includes movie.errors[:youtube_url], 'はYouTubeの動画IDまたはURLを入力してください'
  end

  test 'search by title' do
    assert_includes Movie.search('Inception'), movies(:one)
    assert_not_includes Movie.search('Inception'), movies(:two)
  end

  test 'search returns none for blank keyword' do
    # 空キーワードで全件を返すと検索ページが全件ロードになるため、0件を返す仕様。
    assert_equal 0, Movie.search('').count
    assert_equal 0, Movie.search(nil).count
  end

  test 'image presence accepts legacy string url without attachment' do
    # シード投入済み映画は文字列カラムにURLを持つだけで添付が無い。
    # この状態でも有効(=画像を再アップロードせずに編集できる)であることを担保する。
    movie = Movie.new(title: 'T', director: 'D', category: 'C', user: users(:one))
    movie[:image] = 'https://example.com/poster.jpg' # レガシー文字列カラム(seedと同等)
    assert movie.valid?, movie.errors.full_messages.to_sentence
  end

  test 'image presence rejects when neither attachment nor string url' do
    movie = Movie.new(title: 'T', director: 'D', category: 'C', user: users(:one))
    assert_not movie.valid?
    assert_includes movie.errors[:image], "can't be blank"
  end

  test 'create_all_ranks orders by likes_count' do
    movies(:one).update_columns(likes_count: 5)
    movies(:two).update_columns(likes_count: 10)
    
    ranks = Movie.create_all_ranks
    assert_equal movies(:two), ranks.first
    assert_equal movies(:one), ranks.second
  end
  
  test 'likes_total returns likes_count as integer' do
    movies(:one).update_columns(likes_count: 3)
    assert_equal 3, movies(:one).likes_total
  end
end
