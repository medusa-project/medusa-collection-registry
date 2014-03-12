And(/^the file group named '(.*)' has a cfs file for the path '(.*)' with red flags with fields:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  table.hashes.each do |h|
    cfs_file.red_flags.create(h)
  end
end

When(/^I view the first red flag for the file group named '(.*)' for the cfs file for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  visit red_flag_path(cfs_file.red_flags.first)
end

Then(/^I should be editing the first red flag for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(edit_red_flag_path(cfs_file.red_flags.first))
end

Then(/^I should be viewing the first red flag for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(red_flag_path(cfs_file.red_flags.first))
end

Then(/^I should be viewing the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(cfs_file_path(cfs_file))
end