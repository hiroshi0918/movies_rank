json.array! @movies do |movie|
  json.id movie.id
  json.title movie.title
  json.image movie.image_url
  json.count movie.likes_total
end
