Then /^A repository with title '(.*)' should exist$/ do |repository_title|
  Repository.find_by_title(repository_title).should_not be_nil
end

And /^I have repositories with fields:$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create :repository, hash
  end
end

And /^the repository titled '(.*)' is managed by '(.*)'$/ do |title, net_id|
  person = FactoryGirl.create(:person, :net_id => net_id,)
  FactoryGirl.create(:repository, :contact => person,  :title => title)
end

Then /^I should be on the repository index page$/ do
  current_path.should == repositories_path
end

Then /^I should be on the edit page for the repository titled '(.*)'$/ do |title|
  current_path.should == edit_repository_path(Repository.find_by_title(title))
end

Then /^I should be on the view page for the repository titled '(.*)'$/ do |title|
  current_path.should == repository_path(Repository.find_by_title(title))
end

Then /^I should be on the repository creation page$/ do
  current_path.should == new_repository_path
end

And /^the repository titled '(.*)' has collections with fields:$/ do |repository_title, table|
  repository = Repository.find_or_create_by_title(repository_title)
  table.hashes.each do |hash|
    FactoryGirl.create(:collection, hash.merge(:repository => repository))
  end
end

Then /^I should see the repository collection table$/ do
  page.should have_selector('table#collections')
end

And /^I click on 'Delete' in the collections table$/ do
  within_table('collections') do
    click_on 'Delete'
  end
end

Then /^I should see all repository fields$/ do
  ['Title', 'URL', 'Notes', 'Address 1', 'Address 2', 'City', 'State', 'Zip', 'Phone Number', 'Email'].each do |field|
    step "I should see '#{field}'"
  end
end

When /^I go to the repository creation page$/ do
  visit new_repository_path
end

When /^I go to the repository index page$/ do
  visit repositories_path
end

When /^I view the repository titled '(.*)'$/ do |title|
  visit repository_path(Repository.find_by_title(title))
end

When /^I edit the repository titled '(.*)'$/ do |title|
  visit edit_repository_path(Repository.find_by_title(title))
end