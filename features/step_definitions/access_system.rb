And /^The access system named '(.*)' exists$/ do |name|
  FactoryGirl.create(:access_system, :name => name)
end

And /^There are access systems named:$/ do |table|
 table.headers.each do |header|
   step "The access system named '#{header}' exists"
 end
end

When /^I go to the access system index page$/ do
  visit access_systems_path
end

Then /^I should be on the access system index page$/ do
  current_path.should == access_systems_path
end

When /^I view the access system named '(.*)'$/ do |name|
  visit access_system_path(AccessSystem.find_by_name(name))
end

Then /^I should be on the view page for the access system named '(.*)'$/ do |name|
  current_path.should == access_system_path(AccessSystem.find_by_name(name))
end

When /^I edit the access system named '(.*)'$/ do |name|
  visit edit_access_system_path(AccessSystem.find_by_name(name))
end

Then /^I should be on the edit page for the access system named '(.*)'$/ do |name|
  current_path.should == edit_access_system_path(AccessSystem.find_by_name(name))
end

And /^There should be no access system named '(.*)'$/ do |name|
  AccessSystem.find_by_name(name).should be_nil
end

Then /^I should be on the access system creation page$/ do
  current_path.should == new_access_system_path
end

Given(/^the collection titled '(.*)' has an access system named '(.*)'$/) do |title, name|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  access_system = AccessSystem.find_by_name(name) || FactoryGirl.create(:access_system, :name => name)
  collection.access_systems << access_system
end
