require 'fileutils'
And(/^there is a cfs directory '(.*)'$/) do |path|
  FileUtils.mkdir_p(cfs_local_path(path))
end

And(/^the cfs directory '(.*)' has files:$/) do |path, table|
  table.headers.each do |file_name|
    FileUtils.touch(cfs_local_path(path, file_name))
  end
end

When(/^I view the cfs path '(.*)'$/) do |path|
  visit cfs_show_path(:path => path)
end

Then(/^I should be viewing the cfs directory '(.*)'$/) do  |path|
  current_path.should == cfs_show_path(:path => path)
end

Then(/^I should be viewing the cfs file '(.*)'$/) do |path|
  current_path.should == cfs_show_path(:path => path)
end

def cfs_local_path(*args)
  File.join(MedusaRails3::Application.cfs_root, *args)
end