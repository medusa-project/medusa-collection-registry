#must pass in directory
json.id directory.id
json.name directory.path
json.relative_pathname directory.relative_path
json.path cfs_directory_path(directory, format: :json)
json.uuid directory.uuid
