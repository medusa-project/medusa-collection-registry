Then(/^I should be viewing the cfs root directory for the file group named '(.*)'$/) do |name|
  file_group = FileGroup.find_by(name: name)
  expect(current_path).to eq(cfs_directory_path(file_group.cfs_directory))
end

When(/^I view the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit cfs_directory_path(file_group.cfs_directory_at_path(path))
end

Then(/^I should be viewing the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  expect(current_path).to eq(cfs_directory_path(file_group.cfs_directory_at_path(path)))
end