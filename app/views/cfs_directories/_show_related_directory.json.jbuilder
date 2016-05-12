#must pass in directory
json.id directory.id
json.name directory.path
json.path cfs_directory_path(directory, format: :json)
json.uuid directory.uuid
