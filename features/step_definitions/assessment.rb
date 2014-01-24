And /^the collection titled '(.*)' has assessments with fields:$/ do |title, table|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, title => title)
  table.hashes.each do |hash|
    FactoryGirl.create(:assessment, hash.merge({:assessable => collection}))
  end
end

And /^the file group with location '(.*)' has assessments with fields:$/ do |location, table|
  file_group = FileGroup.find_by_external_file_location(location) || FactoryGirl.create(:file_group, :location => location)
  table.hashes.each do |hash|
    FactoryGirl.create(:assessment, hash.merge({:assessable => file_group}))
  end
end

Then /^I should be on the view page for the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  current_path.should == assessment_path(find_assessment(date, title))
end

Then /^I should be on the view page for the assessment with date '(.*)' for the file group with location '(.*)'$/ do |date, location|
  current_path.should == assessment_path(find_file_group_assessment(date, location))
end

Then(/^I should be on the view page for the assessment named '(.*)'$/) do |name|
  current_path.should == assessment_path(Assessment.find_by_name(name))
end

When /^I view the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  visit assessment_path(find_assessment(date, title))
end

When /^I edit the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
    visit edit_assessment_path(find_assessment(date, title))
end

When(/^I view the assessment named '(.*)'$/) do |name|
  visit assessment_path(Assessment.find_by_name(name))
end

Then /^I should be on the edit page for the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  current_path.should == edit_assessment_path(find_assessment(date, title))
end

Then /^I should be on the new assessment page$/ do
  current_path.should == new_assessment_path
end

And /^The collection titled '(.*)' should not have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should be_nil
end

And /^The collection titled '(.*)' should have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should_not be_nil
end

Then /^I should see an assessment table$/ do
  page.should have_selector('table#assessments')
end

Given /^I am editing an assessment$/ do
  visit edit_assessment_path(FactoryGirl.create(:assessment))
end

Then /^a visitor is unauthorized to start an assessment for the collection titled '(.*)'$/ do |title|
  rack_login('a visitor')
  get new_assessment_path(:assessable_type => 'Collection',
                          :assessable_id => Collection.where(:title => title).first.id)
  assert last_response.redirect?
  assert last_response.location.match(/#{unauthorized_path}$/)
end

Then /^a visitor is unauthorized to create an assessment for the collection titled '(.*)'$/ do |title|
  rack_login('a visitor')
  post assessments_path(:assessment => {:assessable_type => 'Collection',
                                        :assessable_id => Collection.where(:title => title).first.id})
  assert last_response.redirect?
  assert last_response.location.match(/#{unauthorized_path}$/)
end

private

def find_assessment(date, collection_title)
  collection = Collection.find_by_title(collection_title)
  collection.assessments.where(:date => Date.parse(date)).first
end

def find_file_group_assessment(date, location)
  file_group = FileGroup.find_by_external_file_location(location)
  file_group.assessments.where(:date => Date.parse(date)).first
end