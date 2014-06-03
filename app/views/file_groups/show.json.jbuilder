json.id @file_group.id
json.name @file_group.name
json.collection_id @collection.id
json.external_file_location @file_group.external_file_location
json.type @file_group.file_type_name
json.storage_level @file_group.json_storage_level
if @file_group.cfs_directory.present?
  json.cfs_directory do
    directory = @file_group.cfs_directory
    json.id directory.id
    json.path cfs_directory_path(directory, format: :json)
    json.name directory.path
  end
end
