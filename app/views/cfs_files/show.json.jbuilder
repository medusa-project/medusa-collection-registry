json.(@file, :id, :name, :md5_sum, :content_type)
json.size @file.size.to_i
json.mtime @file.mtime.iso8601
json.directory do
  json.id @directory.id
  json.name @directory.path
  json.path cfs_directory_path(@directory, format: :json)
end