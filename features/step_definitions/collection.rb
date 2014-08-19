require 'utils/luhn'

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

And /^I should see a list of all collections$/ do
  page.should have_selector('table#collections')
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
