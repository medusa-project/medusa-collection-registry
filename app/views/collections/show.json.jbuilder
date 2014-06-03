json.(@collection, :id, :uuid, :title)
json.file_groups @collection.file_groups do |file_group|
  json.id file_group.id
  json.path file_group_path(file_group, format: :json)
  json.name file_group.name
  json.storage_level file_group.json_storage_level
end
