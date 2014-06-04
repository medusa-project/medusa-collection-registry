json.partial! 'cfs_files/show_related_file_detailed', file: @file
json.directory do
  json.partial! 'cfs_directories/show_related_directory', directory: @directory
end