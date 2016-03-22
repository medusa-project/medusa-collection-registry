json.cache!(cache_key_for_all(Collection)) do
  json.array! @collections do |collection|
    json.id collection.id
    json.path collection_path(collection)
  end
end