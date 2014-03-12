And(/^the file group named '(.*)' has a cfs file for the path '(.*)' with red flags with fields:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  table.hashes.each do |h|
    cfs_file.red_flags.create(h)
  end
end