require 'utils/luhn'

And /^the repository titled '(.*)' should have a collection titled '(.*)'$/ do |repository_title, collection_title|
  Repository.find_by_title(repository_title).collections.where(:title => collection_title).count.should == 1
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

When(/^I click on '(.*)' in the (.*) actions and delayed jobs are run$/) do |link, section|
  step "I click on '#{link}' in the #{section} actions"
  step "delayed jobs are run"
end

When /^I start a new collection for the repository titled '(.*)'$/ do |title|
  steps %Q( When I view the repository with title '#{title}'
            And I click on 'Add Collection')
end

When /^I view MODS for the collection titled '(.*)'$/ do |title|
  visit collection_path(Collection.find_by_title(title), :format => 'xml')
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

And /^I should see a list of all collections$/ do
  page.should have_selector('table#collections')
end

And /^the collection titled '(.*)' has resource types named:$/ do |title, table|
  step "the collection with title '#{title}' exists"
  collection = Collection.find_by(title: title)
  table.headers.each do |name|
    step "the resource type with name '#{name}' exists"
    collection.resource_types << ResourceType.find_by(name: name)
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
  Utils::Luhn.verify(Collection.find_by_title(title).uuid).should be_truthy
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
