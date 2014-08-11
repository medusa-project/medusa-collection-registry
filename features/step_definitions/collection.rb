require 'utils/luhn'

Then /^I should be on the new collection page$/ do
  current_path.should == new_collection_path
end

Then /^I should be on the view page for the collection titled '(.*)'$/ do |title|
  current_path.should == collection_path(Collection.find_by_title(title))
end

Then /^I should be on the edit page for the collection titled '(.*)'$/ do |title|
  current_path.should == edit_collection_path(Collection.find_by_title(title))
end

And /^the repository titled '(.*)' should have a collection titled '(.*)'$/ do |repository_title, collection_title|
  Repository.find_by_title(repository_title).collections.where(:title => collection_title).count.should == 1
end

Given /^There is a collection titled '(.*)'$/ do |title|
  ensure_collection(title)
end

And /^I click on 'Delete' in the assessments table$/ do
  within_table('assessments') do
    click_on 'Delete'
  end
end

And /^the collection titled 'Dogs' should have (\d+) assessments$/ do |count|
  Collection.find_by_title('Dogs').assessments.count.should == count.to_i
end

Then /^I should see the file group collection table$/ do
  page.should have_selector('table#file_groups')
end

And /^I click on '(.*)' in the file groups table$/ do |button|
  within_table('file_groups') do
    click_on(button)
  end
end

When(/^I click on '(.*)' in the attachments section$/) do |button|
  within('#attachments') do
    click_on(button)
  end
end

When(/^I click on '(.*)' in the (.*) actions$/) do |link, section|
  within(".#{section}-actions") do
    click_on(link)
  end
end

When /^I start a new collection for the repository titled '(.*)'$/ do |title|
  steps %Q( When I view the repository titled '#{title}'
            And I click on 'Add Collection')
end

Given /^I am editing a collection$/ do
  visit edit_collection_path(FactoryGirl.create(:collection))
end

When /^I view the collection titled '(.*)'$/ do |title|
  visit collection_path(Collection.find_by_title(title))
end

When /^I view MODS for the collection titled '(.*)'$/ do |title|
  visit collection_path(Collection.find_by_title(title), :format => 'xml')
end

When /^I edit the collection titled '(.*)'$/ do |title|
  visit edit_collection_path(Collection.find_by_title(title))
end

And /^I check access system '(.*)'$/ do |name|
  check(name)
end

And /^The collection titled '(.*)' should have (\d+) access systems$/ do |title, count|
  Collection.find_by_title(title).access_systems.count.should == count.to_i
end

And /^The collection titled '(.*)' should have access system named '(.*)'$/ do |title, name|
  Collection.find_by_title(title).access_systems.where(:name => name).count.should == 1
end

When /^I go to the collection index page$/ do
  visit collections_path
end

Then /^I should be on the collection index page$/ do
  current_path.should == collections_path
end

And /^I should see a list of all collections$/ do
  page.should have_selector('table#collections')
end

And /^the collection titled '(.*)' has resource types named:$/ do |title, table|
  collection = ensure_collection(title)
  table.headers.each do |name|
    collection.resource_types << ensure_resource_type(name)
  end
end

And /^I uncheck resource type '(.*)'$/ do |name|
  within('#collection_resource_types') do
    uncheck(name)
  end
end

And /^I check resource type '(.*)'$/ do |name|
  within('#collection_resource_types') do
    check(name)
  end
end

And /^The collection titled '(.*)' has preservation priority '(.*)'$/ do |title, priority|
  collection = Collection.find_by_title(title)
  collection.preservation_priority = PreservationPriority.find_by_name(priority)
  collection.save
end

And /^The collection titled '(.*)' should have preservation priority '(.*)'$/ do |title, priority|
  Collection.find_by_title(title).preservation_priority.name.should == priority
end

And /^I should see the UUID of the collection titled '(.*)'$/ do |title|
  steps "Then I should see '#{Collection.find_by_title(title).uuid}'"
end

Then /^The collection titled '(.*)' should have a valid UUID$/ do |title|
  Utils::Luhn.verify(Collection.find_by_title(title).uuid).should be_true
end

And(/^I submit the new event form on the collection view page$/) do
  within('#event_forms') do
    click_on 'Create Event'
  end
end

When(/^I view events for the collection titled '(.*)'$/) do |title|
  visit events_collection_path(Collection.find_by(title: title))
end

And(/^the collection titled '(.*)' has an assessment named '(.*)'$/) do |collection_title, assessment_name|
  c = Collection.find_by_title(collection_title)
  FactoryGirl.create(:assessment, :name => assessment_name, :assessable_id => c.id, :assessable_type => c.class.to_s)
end

private

def ensure_collection(title)
  Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
end

def ensure_resource_type(name)
  ResourceType.find_by_name(name) || FactoryGirl.create(:resource_type, :name => name)
end