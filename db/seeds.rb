require 'open-uri'
require 'cgi'
require "net/http"
require "json"
require "uri"

PLACEHOLDER_POSTER_URL = "https://placehold.co/600x900/141414/E5E5E5?text=No+Poster"

def poster_available?(url)
  uri = URI.parse(url)
  request_path = uri.request_uri.presence || "/"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
    http.request_head(request_path)
  end

  return true if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  return false unless response.code.to_i == 405

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
    http.request_get(request_path)
  end

  response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
rescue StandardError
  false
end

def resolved_poster_url(original_title, image_url, fallback_images)
  fallback_url = fallback_images[original_title] || PLACEHOLDER_POSTER_URL
  return fallback_url if image_url.blank?

  poster_available?(image_url) ? image_url : fallback_url
end

puts 'Cleaning up database...'
Like.delete_all
Comment.delete_all
Movie.destroy_all
User.destroy_all

puts 'Creating users...'
users = []
10.times do |i|
  users << User.create!(
    nickname: "User #{i + 1}",
    email: "user#{i + 1}@example.com",
    password: 'password123'
  )
end

puts "Created #{User.count} users."

puts 'Creating 100 real movies...'

url = URI("https://raw.githubusercontent.com/erik-sytnyk/movies-list/master/db.json")
res = Net::HTTP.get(url)
movies_data = JSON.parse(res)["movies"]

ja_titles = {
  "The Shawshank Redemption" => "ショーシャンクの空に",
  "The Godfather" => "ゴッドファーザー",
  "The Godfather: Part II" => "ゴッドファーザー PART II",
  "The Dark Knight" => "ダークナイト",
  "12 Angry Men" => "十二人の怒れる男",
  "Schindler's List" => "シンドラーのリスト",
  "Pulp Fiction" => "パルプ・フィクション",
  "The Lord of the Rings: The Return of the King" => "ロード・オブ・ザ・リング/王の帰還",
  "The Good, the Bad and the Ugly" => "続・夕陽のガンマン",
  "Fight Club" => "ファイト・クラブ",
  "The Lord of the Rings: The Fellowship of the Ring" => "ロード・オブ・ザ・リング",
  "Forrest Gump" => "フォレスト・ガンプ",
  "Star Wars: Episode V - The Empire Strikes Back" => "スター・ウォーズ エピソード5/帝国の逆襲",
  "Inception" => "インセプション",
  "The Lord of the Rings: The Two Towers" => "ロード・オブ・ザ・リング/二つの塔",
  "One Flew Over the Cuckoo's Nest" => "カッコーの巣の上で",
  "Goodfellas" => "グッドフェローズ",
  "The Matrix" => "マトリックス",
  "Seven Samurai" => "七人の侍",
  "Star Wars: Episode IV - A New Hope" => "スター・ウォーズ エピソード4/新たなる希望",
  "City of God" => "シティ・オブ・ゴッド",
  "Se7en" => "セブン",
  "The Silence of the Lambs" => "羊たちの沈黙",
  "It's a Wonderful Life" => "素晴らしき哉、人生!",
  "Life Is Beautiful" => "ライフ・イズ・ビューティフル",
  "The Usual Suspects" => "ユージュアル・サスペクツ",
  "Léon: The Professional" => "レオン",
  "Spirited Away" => "千と千尋の神隠し",
  "Saving Private Ryan" => "プライベート・ライアン",
  "Interstellar" => "インターステラー",
  "The Green Mile" => "グリーンマイル",
  "Parasite" => "パラサイト 半地下の家族",
  "Leon" => "レオン",
  "The Pianist" => "戦場のピアニスト",
  "Gladiator" => "グラディエーター",
  "Terminator 2: Judgment Day" => "ターミネーター2",
  "Back to the Future" => "バック・トゥ・ザ・フューチャー",
  "Psycho" => "サイコ",
  "The Lion King" => "ライオン・キング",
  "Modern Times" => "モダン・タイムス",
  "Grave of the Fireflies" => "火垂るの墓",
  "Whiplash" => "セッション",
  "The Departed" => "ディパーテッド",
  "Memento" => "メメント",
  "Apocalypse Now" => "地獄の黙示録",
  "The Prestige" => "プレステージ",
  "Alien" => "エイリアン",
  "Django Unchained" => "ジャンゴ 繋がれざる者",
  "The Shining" => "シャイニング",
  "WALL·E" => "ウォーリー",
  "Spider-Man: Into the Spider-Verse" => "スパイダーマン:スパイダーバース",
  "Avengers: Infinity War" => "アベンジャーズ/インフィニティ・ウォー",
  "Coco" => "リメンバー・ミー",
  "The Dark Knight Rises" => "ダークナイト ライジング",
  "Joker" => "ジョーカー",
  "Your Name." => "君の名は。",
  "Aliens" => "エイリアン2",
  "Oldboy" => "オールド・ボーイ",
  "Once Upon a Time in America" => "ワンス・アポン・ア・タイム・イン・アメリカ",
  "Avengers: Endgame" => "アベンジャーズ/エンドゲーム"
}

ja_genres = {
  "Action" => "アクション", "Adventure" => "アドベンチャー", "Animation" => "アニメ",
  "Biography" => "伝記", "Comedy" => "コメディ", "Crime" => "犯罪", "Documentary" => "ドキュメンタリー",
  "Drama" => "ドラマ", "Family" => "ファミリー", "Fantasy" => "ファンタジー", "History" => "歴史",
  "Horror" => "ホラー", "Music" => "音楽", "Musical" => "ミュージカル", "Mystery" => "ミステリー",
  "Romance" => "ロマンス", "Sci-Fi" => "SF", "Sport" => "スポーツ", "Thriller" => "スリラー",
  "War" => "戦争", "Western" => "西部劇"
}

fallback_images = {
  "Kiss Kiss Bang Bang" => "https://image.tmdb.org/t/p/w500/kSraXXk2E7zVqX2u2r9rAW6qfL8.jpg",
  "One Flew Over the Cuckoo's Nest" => "https://image.tmdb.org/t/p/w500/3jcbjzxcNiHMprNaXlz18T0mOSG.jpg",
  "The Hitchhiker's Guide to the Galaxy" => "https://image.tmdb.org/t/p/w500/yA2R1Xg9W9C5vHh7QXXrV2Vq7Rz.jpg"
}

valid_movies = movies_data.reject { |movie| movie["posterUrl"].nil? }.uniq { |movie| movie["title"] }.take(100)

valid_movies.each_with_index do |data, index|
  original_title = data["title"]
  title = ja_titles[original_title] || original_title
  director = data["director"]
  first_genre = data["genres"]&.first || "Drama"
  category = ja_genres[first_genre] || first_genre
  detail = data["plot"]
  poster_url = resolved_poster_url(original_title, data["posterUrl"], fallback_images)

  begin
    Movie.insert({
      title: title,
      director: director,
      category: category,
      detail: detail,
      youtube_url: nil,
      user_id: users.sample.id,
      image: poster_url,
      created_at: Time.current,
      updated_at: Time.current
    })
    puts "Created movie #{index + 1}/100: #{title}"
  rescue => e
    puts "Failed to save #{title}: #{e.message}"
  end
end

puts "Created #{Movie.count} movies."

puts 'Creating comments and likes...'
comments_pool = [
  "最高でした！", "おすすめします！", "もう一度見たい作品です。",
  "思っていたより面白かったです！", "映像が綺麗でした。", "ストーリーに感動しました",
  "監督のこだわりを感じる一作でした", "少し期待はずれでしたが、音楽はよかったです",
  "家族で見ると楽しめるかも！", "絶対に映画館でみるべき！",
  "俳優の演技が光っていました。", "最後は涙が止まりませんでした。",
  "何度見ても新しい発見があります！"
]

Movie.all.each do |movie|
  random_users = users.sample(rand(2..7))

  random_users.each do |user|
    if rand(100) > 40
      Comment.create!(
        movie: movie,
        user: user,
        text: comments_pool.sample
      )
    end

    if rand(100) > 20
      Like.find_or_create_by!(
        movie: movie,
        user: user
      )
    end
  end
end

puts "Created #{Comment.count} comments and #{Like.count} likes."
puts "\nSeeding successfully complete! 🎉"
