json.array! @movies do |movie|
  json.id movie.id
  json.title movie.title
  json.image movie.image.url
  json.count movie.liked_users.count
end