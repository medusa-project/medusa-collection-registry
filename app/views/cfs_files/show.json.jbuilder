json.(@file, :id, :name, :md5_sum, :content_type)
json.size @file.size.to_i
json.mtime @file.mtime.iso8601
json.directory do
  json.partial! 'cfs_directories/show_related_directory', directory: @directory
end