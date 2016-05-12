json.id @directory.id
json.uuid @directory.uuid
json.name @directory.path
json.subdirectories @directory.subdirectories, partial: 'cfs_directories/show_related_directory', as: :directory
json.files @directory.cfs_files, partial: 'cfs_files/show_related_file_detailed', as: :file, locals: {show_path: true}
parent = @directory.parent
if parent and parent.is_a?(CfsDirectory)
  json.parent_directory do
    json.partial! 'cfs_directories/show_related_directory', directory: parent
  end
end