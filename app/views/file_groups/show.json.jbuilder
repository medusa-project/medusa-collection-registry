json.(@file_group, :id, :name, :external_file_location)
json.collection_id @collection.id
json.type @file_group.file_type_name
json.storage_level @file_group.json_storage_level
if @file_group.cfs_directory.present?
  json.cfs_directory do
    json.partial! 'cfs_directories/show_related_directory', directory: @file_group.cfs_directory
  end
end
