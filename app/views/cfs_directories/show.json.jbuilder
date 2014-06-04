json.id @directory.id
json.name @directory.path
json.subdirectories @directory.subdirectories, partial: 'cfs_directories/show_related_directory', as: :directory
json.files @directory.cfs_files, partial: 'cfs_files/show_related_file_detailed', as: :file, show_path: true
parent_directory = @directory.parent_cfs_directory
if parent_directory
  json.parent_directory do
    json.partial! 'cfs_directories/show_related_directory', directory: parent_directory
  end
end