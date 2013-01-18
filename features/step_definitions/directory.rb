#this is a little roundabout - a factory is hard because a directory needs a collection, but a collection
#creates its own root directory
Given /^I have a directory named '(.*)'$/ do |name|
  collection = FactoryGirl.create(:collection)
  directory = collection.root_directory
  directory.name = name
  directory.save
end