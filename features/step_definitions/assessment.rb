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

And /^The collection titled '(.*)' should not have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should be_nil
end

And /^The collection titled '(.*)' should have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should_not be_nil
end

Then /^I should see an assessment table$/ do
  page.should have_selector('table#assessments')
end

Then /^a visitor is unauthorized to start an assessment for the collection titled '(.*)'$/ do |title|
  rack_login('a visitor')
  get new_assessment_path(:assessable_type => 'Collection',
                          :assessable_id => Collection.where(:title => title).first.id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

Then /^a visitor is unauthorized to create an assessment for the collection titled '(.*)'$/ do |title|
  rack_login('a visitor')
  post assessments_path(:assessment => {:assessable_type => 'Collection',
                                        :assessable_id => Collection.where(:title => title).first.id})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
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