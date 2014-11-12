Then(/^I should be viewing the cfs root directory for the file group named '(.*)'$/) do |name|
  file_group = FileGroup.find_by(name: name)
  expect(current_path).to eq(cfs_directory_path(file_group.cfs_directory))
end

When(/^I view the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit cfs_directory_path(file_group.cfs_directory_at_path(path))
end

Given(/^I public view the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit public_cfs_directory_path(file_group.cfs_directory_at_path(path))
end

Then(/^I should be viewing the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  expect(current_path).to eq(cfs_directory_path(file_group.cfs_directory_at_path(path)))
end

Then(/^I should be public viewing the cfs directory for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  expect(current_path).to eq(public_cfs_directory_path(file_group.cfs_directory_at_path(path)))
end

When(/^the cfs directory for the path '(.*)' for the file group named '(.*)' has an assessment scheduled$/) do |path, name|
  file_group = FileGroup.find_by(name: name)
  cfs_directory = file_group.cfs_directory_at_path(path)
  Job::CfsInitialDirectoryAssessment.create(cfs_directory: cfs_directory, file_group: file_group)
end

Then(/^the file group named '(.*)' should have root cfs directory with path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  expect(file_group.cfs_directory.path).to eq(path)
end

When(/^I request JSON for the cfs directory with id '(\d+)'$/) do |id|
  visit cfs_directory_path(CfsDirectory.find(id), format: :json)
end

Given(/^there are cfs directories with fields:$/) do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:cfs_directory, hash)
  end
end

And(/^there are cfs subdirectories of the cfs directory with path '(.*)' with fields:$/) do |path, table|
  parent = CfsDirectory.find_by(path: path)
  table.hashes.each do |hash|
    parent.subdirectories.create!(hash.merge(root_cfs_directory_id: parent.root_cfs_directory_id))
  end
end

And(/^there are cfs files of the cfs directory with path '(.*)' with fields:$/) do |path, table|
  parent = CfsDirectory.find_by(path: path)
  table.hashes.each do |hash|
    parent.cfs_files.create!(hash)
  end
end

Then(/^the cfs directory for the path '(.*)' should have tree size (\d+) and count (\d+)$/) do |path, size, count|
  cfs_directory = CfsDirectory.find_by(path: path)
  expect(cfs_directory.tree_size).to eq(size.to_d)
  expect(cfs_directory.tree_count).to eq(count.to_d)
end