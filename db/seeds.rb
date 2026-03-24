require_relative "../app/services/movie_catalog"
require_relative "../app/services/movie_catalog_importer"

puts "Cleaning up database..."
Like.delete_all
Comment.delete_all
Movie.destroy_all
User.destroy_all

puts "Creating users..."
users = Array.new(10) do |index|
  User.create!(
    nickname: "User #{index + 1}",
    email: "user#{index + 1}@example.com",
    password: "password123"
  )
end

puts "Created #{User.count} users."
puts "Importing local movie catalog..."

movies = MovieCatalogImporter.new(users: users).import!

puts "Created #{movies.count} movies."
puts "Creating comments and likes..."

comments_pool = [
  "最高でした！", "おすすめします！", "もう一度見たい作品です。",
  "思っていたより面白かったです！", "映像が綺麗でした。", "ストーリーに感動しました",
  "監督のこだわりを感じる一作でした", "少し期待はずれでしたが、音楽はよかったです",
  "家族で見ると楽しめるかも！", "絶対に映画館でみるべき！",
  "俳優の演技が光っていました。", "最後は涙が止まりませんでした。",
  "何度見ても新しい発見があります！"
]

Movie.find_each do |movie|
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
puts "\nSeeding successfully complete!"
