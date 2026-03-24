json.array! @movies do |movie|
  json.id movie.id
  json.title movie.title
  json.original_title movie.original_title
  json.image movie_poster_source(movie)
  json.count movie.likes_total
end
