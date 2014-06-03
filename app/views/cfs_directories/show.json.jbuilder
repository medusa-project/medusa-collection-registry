json.id @directory.id
json.name @directory.path
json.subdirectories @directory.subdirectories do |subdirectory|
  json.partial! 'cfs_directories/show_related_directory', directory: subdirectory
end
json.files @directory.cfs_files do |file|
  json.partial! 'cfs_files/show_related_file', file: file
end
parent_directory = @directory.parent_cfs_directory
if parent_directory
  json.parent_directory do
    json.partial! 'cfs_directories/show_related_directory', directory: parent_directory
  end
end