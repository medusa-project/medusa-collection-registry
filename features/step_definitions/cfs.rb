require 'fileutils'
And(/^there is a physical cfs directory '(.*)'$/) do |path|
  FileUtils.mkdir_p(cfs_local_path(path))
end

And(/^I clear the cfs root directory$/) do
  Dir[File.join(CfsRoot.instance.path, '*')].each do |entry|
    FileUtils.rm_rf(entry)
  end
end

And(/^the cfs directory '(.*)' has files:$/) do |path, table|
  table.headers.each do |file_name|
    FileUtils.touch(cfs_local_path(path, file_name))
  end
end

And(/^the physical cfs directory '(.*)' has a file '(.*)' with contents '(.*)'$/) do |directory, file, contents|
  step "there is a physical cfs directory '#{directory}'"
  File.open(cfs_local_path(directory, file), 'w') do |f|
    f.write contents
  end
end

And(/^I remove the cfs path '(.*)'$/) do |path|
  FileUtils.rm_rf(cfs_local_path(path))
end

When(/^I view the cfs path '(.*)'$/) do |path|
  visit cfs_show_path(path: path)
end

Then(/^I should be viewing the cfs file '(.*)'$/) do |path|
  current_path.should == cfs_show_path(path: path)
end

Given(/^the file group titled '(.*)' has cfs root '(.*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  root_directory = FactoryGirl.create(:cfs_directory, path: path)
  file_group.cfs_directory = root_directory
  file_group.save!
end

Given(/^the file group titled '(.*)' has cfs root '(.*)' and delayed jobs are run$/) do |title, path|
  step "the file group titled '#{title}' has cfs root '#{path}'"
  step "delayed jobs are run"
end

When(/^I set the cfs root of the file group titled '(.*)' to '(.*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  new_root = CfsDirectory.find_by(path: path) || FactoryGirl.create(:cfs_directory, path: path)
  file_group.cfs_directory = new_root
  file_group.save!
end

When(/^I set the cfs root of the file group titled '(.*)' to '(.*)' and delayed jobs are run$/) do |name, path|
  step "I set the cfs root of the file group titled '#{name}' to '#{path}'"
  step "delayed jobs are run"
end

And(/^I run assessments on the the file group titled '(.*)'$/) do |title|
  file_group = BitLevelFileGroup.where(title: title).first
  file_group.schedule_initial_cfs_assessment
  step "delayed jobs are run"
end

When(/^I view fits for the cfs file '(.*)'$/) do |path|
  visit cfs_fits_info_path(path: path)
end


And(/^the cfs directory '(.*)' contains cfs fixture file '(.*)'$/) do |path, fixture|
  ensure_cfs_path(path)
  FileUtils.copy_file(File.join(Rails.root, 'features', 'fixtures', fixture),
                      cfs_local_path(path, fixture))
end

Given(/^the physical cfs directory '(.*)' has the data of bag '(.*)'$/) do |path, bag_name|
  cfs_directory = CfsDirectory.where(path: path).first
  bag_data_directory = File.join(bag_path(bag_name), 'data')
  Dir.chdir(bag_data_directory) do
    Dir['**/*'].each do |file|
      if File.file?(file)
        target = File.join(cfs_directory.absolute_path, file)
        FileUtils.mkdir_p(File.dirname(target))
        FileUtils.copy(file, target)
      end
    end
  end
end

def ensure_cfs_path(path)
  FileUtils.mkdir_p(File.join(CfsRoot.instance.path, path))
end

def cfs_local_path(*args)
  File.join(CfsRoot.instance.path, *args)
end

def bag_path(name)
  File.join(Rails.root, 'features', 'fixtures', 'bags', name)
end