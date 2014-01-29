require 'fileutils'
And(/^there is a cfs directory '(.*)'$/) do |path|
  FileUtils.mkdir_p(cfs_local_path(path))
end

And(/^I clear the cfs root directory$/) do
  Dir[File.join(Cfs.root, "*")].each do |entry|
    FileUtils.rm_rf(entry)
  end
end

And(/^the cfs directory '(.*)' has files:$/) do |path, table|
  table.headers.each do |file_name|
    FileUtils.touch(cfs_local_path(path, file_name))
  end
end

And(/^the cfs directory '(.*)' has a file '(.*)' with contents '(.*)'$/) do |directory, file, contents|
  File.open(cfs_local_path(directory, file), 'w') do |f|
    f.write contents
  end
end

And(/^I remove the cfs path '(.*)'$/) do |path|
  FileUtils.rm_rf(cfs_local_path(path))
end

When(/^I view the cfs path '(.*)'$/) do |path|
  visit cfs_show_path(:path => path)
end

Then(/^I should be viewing the cfs directory '(.*)'$/) do |path|
  current_path.should == cfs_show_path(:path => path)
end

Then(/^I should be viewing the cfs file '(.*)'$/) do |path|
  current_path.should == cfs_show_path(:path => path)
end

Given(/^the file group named '(.*)' has cfs root '(.*)'$/) do |name, directory|
  file_group = FileGroup.find_by_name(name)
  file_group.cfs_root = directory
  file_group.save!
end

When(/^I set the cfs root of the file group named '(.*)' to '(.*)'$/) do |name, directory|
  file_group = FileGroup.find_by_name(name)
  file_group.cfs_root = directory
  file_group.save
end

Given(/^the cfs file '(.*)' has FITS xml attached$/) do |path|
  FactoryGirl.create(:cfs_file_info, :path => path, :fits_xml => '<fits/>')
end

When(/^I create FITS for the cfs path '(.*)'$/) do |path|
  Cfs.ensure_fits_for(path)
end

When(/^I update FITS for the cfs path '(.*)'$/) do |path|
  Cfs.update_fits_for(path)
end

And(/^the cfs file '(.*)' should have FITS xml attached$/) do |path|
  CfsFileInfo.find_by_path(path).should_not be_false
end

When(/^I view fits for the cfs file '(.*)'$/) do |path|
  visit cfs_fits_info_path(:path => path)
end

Then(/^the file group named '(.*)' should have cfs root '(.*)'$/) do |name, path|
  FileGroup.find_by_name(name).cfs_root.should == path
end

Then(/^the cfs file '(.*)' should have size '(\d+)'$/) do |path, size|
  CfsFileInfo.find_by_path(path).size.to_i.should == size.to_i
end

And(/^the cfs file '(.*)' should have content type '(.*)'$/) do |path, content_type|
  CfsFileInfo.find_by_path(path).content_type.should == content_type
end

And(/^the cfs file '(.*)' should have md5 sum '(.*)'$/) do |path, md5_sum|
  CfsFileInfo.find_by_path(path).md5_sum.should == md5_sum
end

Then(/^I should be on the fits info page for the cfs file '(.*)'$/) do |path|
  current_path.should == cfs_fits_info_path(:path => path)
end

And(/^the cfs directory '(.*)' contains cfs fixture file '(.*)'$/) do |path, fixture|
  FileUtils.mkdir_p(Cfs.file_path_for(path))
  FileUtils.copy_file(File.join(Rails.root, 'features', 'fixtures', fixture),
                      cfs_local_path(path, fixture))
end

def cfs_local_path(*args)
  File.join(Cfs.root, *args)
end