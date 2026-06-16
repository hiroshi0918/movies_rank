#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "json"
require "net/http"
require "nokogiri"
require "active_support/core_ext/object/blank"
require "yaml"

SOURCE_URL = URI("https://raw.githubusercontent.com/erik-sytnyk/movies-list/master/db.json")
TMDB_HOST = "www.themoviedb.org"
TMDB_IMAGE_HOST = "image.tmdb.org"

JA_GENRES = {
  "Action" => "アクション",
  "Adventure" => "アドベンチャー",
  "Animation" => "アニメ",
  "Biography" => "伝記",
  "Comedy" => "コメディ",
  "Crime" => "犯罪",
  "Documentary" => "ドキュメンタリー",
  "Drama" => "ドラマ",
  "Family" => "ファミリー",
  "Fantasy" => "ファンタジー",
  "History" => "歴史",
  "Horror" => "ホラー",
  "Music" => "音楽",
  "Musical" => "ミュージカル",
  "Mystery" => "ミステリー",
  "Romance" => "ロマンス",
  "Sci-Fi" => "SF",
  "Sport" => "スポーツ",
  "Thriller" => "スリラー",
  "War" => "戦争",
  "Western" => "西部劇"
}.freeze

JA_TITLES = {
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
}.freeze

CATALOG_OVERRIDES = {
  "Valkyrie" => {
    "title" => "ワルキューレ",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/mFxaL3J213HZ53hFyztLtCvxP1u.jpg",
    "movie_path" => "/movie/2253-valkyrie"
  },
  "Looper" => {
    "title" => "LOOPER／ルーパー",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/rPqDpuu2teEqdtjFQoykzQeKCne.jpg",
    "movie_path" => "/movie/59967-looper"
  },
  "Flight" => {
    "title" => "フライト",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/eSAf3zq0XLm8xnIfmRcq7dxbsYt.jpg"
  },
  "The Artist" => {
    "title" => "アーティスト",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/m2GHSghIo81WWM0WvBkHU7abm1P.jpg",
    "movie_path" => "/movie/74643-the-artist"
  },
  "Downfall" => {
    "title" => "ヒトラー ～最期の12日間～",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/lDwGsVilUjd1UWuBQPv4cj5hwQ4.jpg",
    "movie_path" => "/movie/613-der-untergang"
  },
  "Crash" => {
    "title" => "クラッシュ",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/nrXtcwQv8ZjdbY2C3Punrv5IlrR.jpg",
    "movie_path" => "/movie/1640-crash"
  },
  "Chocolat" => {
    "title" => "ショコラ",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/7FBM0PoArkPaJBOR99mzVr1l8Xo.jpg"
  },
  "Hellboy II: The Golden Army" => {
    "title" => "ヘルボーイ／ゴールデン・アーミー",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/cTo9yoUOaSpsecXTVQKOC3INwbj.jpg",
    "movie_path" => "/movie/11253-hellboy-ii-the-golden-army"
  },
  "I-See-You.Com" => {
    "title" => "アイ・シー・ユー・ドットコム",
    "poster_source_url" => "https://image.tmdb.org/t/p/w500/fscHts499XahFEaHquyowRUzOC5.jpg",
    "movie_path" => "/movie/14569-i-see-you-com"
  },
  "Forrest Gump" => {
    "movie_path" => "/movie/13-forrest-gump"
  },
  "Match Point" => {
    "movie_path" => "/movie/116-match-point"
  },
  "The Impossible" => {
    "movie_path" => "/movie/80278-the-impossible"
  }
}.freeze

def fetch_json(uri)
  JSON.parse(Net::HTTP.get(uri))
end

def fetch_html(uri)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (MoviesRank Catalog Generator)"
    request["Accept-Language"] = "ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7"
    http.request(request).body
  end
end

def extract_candidates(document)
  document.css('a.result[href^="/movie/"]').filter_map do |anchor|
    card = anchor.ancestors("div.card").first
    next unless card

    image = card.at_css("img.poster")
    next unless image&.[]("src")

    heading = card.at_css("h2")&.text&.strip.presence || anchor.text.strip
    release_date = card.at_css("span.release_date")&.text.to_s
    released_year = release_date[/\d{4}/]&.to_i

    {
      title: heading,
      year: released_year,
      image_src: image["src"],
      href: anchor["href"]
    }
  end
end

def movie_candidates(title, year)
  queries = ["#{title} y:#{year}", title]

  queries.each do |query|
    3.times do |attempt|
      uri = URI("https://#{TMDB_HOST}/search/movie?query=#{CGI.escape(query)}")
      document = Nokogiri::HTML(fetch_html(uri))
      candidates = extract_candidates(document)
      return candidates if candidates.any?

      sleep(1 + attempt)
    end
  end

  []
end

def pick_candidate(title, year, candidates)
  matching_title_candidates = candidates.select { |candidate| title_matches?(candidate[:title], title) }
  return nearest_year_candidate(year, matching_title_candidates) if matching_title_candidates.any?

  near_year_candidates = candidates.select { |candidate| candidate[:year] && (candidate[:year] - year).abs <= 1 }
  return near_year_candidates.first if near_year_candidates.any?

  candidates.find { |candidate| candidate[:year] == year } || candidates.first
end

def normalized_text(value)
  value.downcase.gsub(/[[:space:][:punct:]・／]+/, "")
end

def title_matches?(candidate_title, original_title)
  candidate_downcase = candidate_title.downcase
  original_downcase = original_title.downcase
  normalized_candidate = normalized_text(candidate_title)
  normalized_original = normalized_text(original_title)

  candidate_downcase.include?("(#{original_downcase})") ||
    candidate_downcase == original_downcase ||
    normalized_candidate.include?(normalized_original)
end

def nearest_year_candidate(year, candidates)
  candidates.min_by do |candidate|
    candidate_year = candidate[:year]
    candidate_year ? (candidate_year - year).abs : 99
  end
end

def poster_url_from(source)
  matched = source.match(%r{/t/p/[^/]+(/[^?"']+)})
  return unless matched

  "https://#{TMDB_IMAGE_HOST}/t/p/w500#{matched[1]}"
end

def verify_poster!(url)
  uri = URI(url)
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
    http.request_head(uri.request_uri)
  end

  return if response.is_a?(Net::HTTPSuccess)

  raise "Poster verification failed for #{url}: #{response.code}"
end

def youtube_trailer_id_for(movie_path)
  return if movie_path.blank?

  uri = URI("https://#{TMDB_HOST}#{movie_path}")
  html = fetch_html(uri)
  matched = html.match(/data-site="YouTube"[^>]*data-id="([A-Za-z0-9_-]{11})"/)
  matched && matched[1]
end

def localized_title(candidate_title, original_title)
  mapped = JA_TITLES[original_title]
  return mapped if mapped.present?

  stripped = candidate_title.gsub(/\s+/, " ").strip
  stripped = stripped.sub(/\s*\([^)]*\)\s*\z/, "").strip if stripped.downcase.include?(original_title.downcase)
  stripped.presence || original_title
end

if $PROGRAM_NAME == __FILE__
  movies = fetch_json(SOURCE_URL).fetch("movies")
  catalog = []
  seen_titles = {}

  movies.each do |movie|
    next if movie["posterUrl"].blank?
    next if seen_titles[movie["title"]]

    seen_titles[movie["title"]] = true

    original_title = movie.fetch("title")
    year = movie.fetch("year").to_i
    candidates = movie_candidates(original_title, year)
    raise "No TMDB candidate found for #{original_title}" if candidates.empty?

    candidate = pick_candidate(original_title, year, candidates)
    override = CATALOG_OVERRIDES[original_title]
    poster_source_url = override&.fetch("poster_source_url", nil) || poster_url_from(candidate.fetch(:image_src))
    raise "No poster URL found for #{original_title}" if poster_source_url.blank?

    verify_poster!(poster_source_url)

    movie_path = override&.fetch("movie_path", nil) || candidate.fetch(:href)
    youtube_url = youtube_trailer_id_for(movie_path)

    catalog << {
      "title" => override&.fetch("title", nil) || localized_title(candidate.fetch(:title), original_title),
      "original_title" => original_title,
      "director" => movie.fetch("director"),
      "category" => JA_GENRES[movie.fetch("genres").first] || movie.fetch("genres").first,
      "detail" => movie.fetch("plot"),
      "poster_source_url" => poster_source_url,
      "youtube_url" => youtube_url
    }

    warn "Processed #{catalog.size}/100: #{original_title}"
    break if catalog.size == 100
  end

  warn "Generated #{catalog.size} catalog entries (ASCII-only localized titles: #{catalog.count { |entry| entry["title"].ascii_only? }})"
  puts YAML.dump(catalog)
end
