#this is a little roundabout - a factory is hard because a directory needs a collection, but a collection
#creates its own root directory
Given /^I have a directory named '(.*)'$/ do |name|
  collection = FactoryGirl.create(:collection)
  directory = collection.root_directory
  directory.name = name
  directory.save
end

And /^the directory named '(.*)' has a subdirectory named '(.*)'$/ do |parent, child|
  parent = Directory.find_by_name(parent)
  parent.children.create(:name => child)
end

When /^I request JSON for the directory named '(.*)'$/ do |name|
  visit directory_path(Directory.find_by_name(name), :format => 'json')
end

When /^I request JSON for the directory named '(.*)' without file information$/ do |name|
  visit directory_path(Directory.find_by_name(name), :format => 'json', :include_files => false)
end

When /^I request JSON for the directory named '(.*)' without subdirectory information$/ do |name|
  visit directory_path(Directory.find_by_name(name), :format => 'json', :include_subdirectories => false)
end