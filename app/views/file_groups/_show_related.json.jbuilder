#must pass in file_group
json.id file_group.id
json.path file_group_path(file_group, format: :json)
json.title file_group.title
json.storage_level file_group.json_storage_level
