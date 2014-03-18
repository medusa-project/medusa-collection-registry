And(/^the file group named '(.*)' has a cfs file for the path '(.*)' with red flags with fields:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  table.hashes.each do |h|
    cfs_file.red_flags.create(h)
  end
end

And(/^the file group named '(.*)' has a cfs file for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  file_group.cfs_directory.ensure_file_at_relative_path(path)
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

And(/^the cfs file at path '(.*)' for the file group named '(.*)' should have (\d+) red flags?$/) do |path, name, count|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(cfs_file.red_flags.count).to eq(count.to_i)
end

When(/^I view the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit cfs_file_path(file_group.cfs_file_at_path(path))
end

When(/^I run an initial cfs file assessment on the file group named '(.*)'$/) do |name|
  FileGroup.find_by(name: name).schedule_initial_cfs_assessment
end

Then(/^the file group named '(.*)' has a cfs file for the path '(.*)' with results:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  expect(cfs_file).not_to be_nil
  table.raw.each do |field, value|
    expect(cfs_file.send(field).to_s).to eq(value)
  end
end
