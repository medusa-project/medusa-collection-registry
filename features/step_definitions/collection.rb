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
  FactoryGirl.create(:collection, :title => title)
end

Then /^I should see the assessment collection table$/ do
  page.should have_selector('table#assessments')
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

When /^I start a new collection for the repository titled '(.*)'$/ do |title|
  steps %Q( When I view the repository titled '#{title}'
            And I click on 'Add Collection')
end

Given /^I am editing a collection$/ do
  visit edit_collection_path(FactoryGirl.create(:collection))
end

When /^I select content type '(.*)'$/ do |type|
  select(type, :from => 'collection_content_type_id')
end

When /^I view the collection titled '(.*)'$/ do |title|
  visit collection_path(Collection.find_by_title(title))
end

When /^I edit the collection titled '(.*)'$/ do |title|
  visit edit_collection_path(Collection.find_by_title(title))
end

And /^I select access system '(.*)'$/ do |name|
  select(name, :from => 'collection_access_system_ids')
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