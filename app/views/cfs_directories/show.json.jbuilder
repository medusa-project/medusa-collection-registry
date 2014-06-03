json.id @directory.id
json.name @directory.path
json.subdirectories @directory.subdirectories do |subdirectory|
  json.id subdirectory.id
  json.name subdirectory.path
  json.path cfs_directory_path(subdirectory, format: :json)
end
json.files @directory.cfs_files do |file|
  json.id file.id
  json.name file.name
  json.path cfs_file_path(file, format: :json)
end
parent_directory = @directory.parent_cfs_directory
if parent_directory
  json.parent_directory do
    json.id parent_directory.id
    json.name parent_directory.path
    json.path cfs_directory_path(parent_directory, format: :json)
  end
end