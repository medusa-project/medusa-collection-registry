require 'fileutils'

When(/^I view the cfs path '([^']*)'$/) do |path|
  visit cfs_show_path(path: path)
end

Then(/^I should be viewing the cfs file '([^']*)'$/) do |path|
  current_path.should == cfs_show_path(path: path)
end

Given(/^the file group titled '([^']*)' has cfs root '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  root_directory = FactoryBot.create(:cfs_directory, path: path)
  file_group.cfs_directory = root_directory
  file_group.save!
end

Given(/^the file group titled '([^']*)' has cfs root '([^']*)' and delayed jobs are run$/) do |title, path|
  step "the file group titled '#{title}' has cfs root '#{path}'"
  step 'delayed jobs are run'
end

When(/^I set the cfs root of the file group titled '([^']*)' to '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  new_root = CfsDirectory.find_by(path: path) || FactoryBot.create(:cfs_directory, path: path)
  file_group.cfs_directory_id = new_root.id
  file_group.save!
  new_root.parent = file_group
  new_root.save!
end

When(/^I set the cfs root of the file group titled '([^']*)' to '([^']*)' and delayed jobs are run$/) do |name, path|
  step "I set the cfs root of the file group titled '#{name}' to '#{path}'"
  step 'delayed jobs are run'
end

And(/^I run assessments on the the file group titled '([^']*)'$/) do |title|
  file_group = BitLevelFileGroup.where(title: title).first
  file_group.schedule_initial_cfs_assessment
  step 'delayed jobs are run'
end

When(/^I view fits for the cfs file '([^']*)'$/) do |path|
  visit cfs_fits_info_path(path: path)
end




