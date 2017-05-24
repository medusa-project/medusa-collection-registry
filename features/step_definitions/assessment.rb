And /^the assessable (.*) with (.*) '([^']*)' has assessments with fields:$/ do |object_type, key, value, table|
  assessable = step "the #{object_type} with #{key} '#{value}' exists"
  table.hashes.each do |hash|
    FactoryGirl.create(:assessment, hash.merge(assessable: assessable))
  end
end

And /^The collection titled '([^']*)' should not have an assessment with date '([^']*)'$/ do |title, date|
  find_assessment(date, title).should be_nil
end

And /^The collection titled '([^']*)' should have an assessment with date '([^']*)'$/ do |title, date|
  find_assessment(date, title).should_not be_nil
end

Then /^I should see an assessment table$/ do
  page.should have_selector('table#assessments')
end

Then /^a user is unauthorized to start an assessment for the collection titled '([^']*)'$/ do |title|
  rack_login('a user')
  get new_assessment_path(assessable_type: 'Collection',
                          assessable_id: Collection.where(title: title).first.id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

Then /^a user is unauthorized to create an assessment for the collection titled '([^']*)'$/ do |title|
  rack_login('a user')
  post assessments_path(assessment: {assessable_type: 'Collection',
                                        assessable_id: Collection.where(title: title).first.id})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

Then /^I should be viewing assessments for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  expect(current_path).to eq(specific_object_path(object_type, key, value, prefix: 'assessments'))
end

private

def find_assessment(date, collection_title)
  collection = Collection.find_by(title: collection_title)
  collection.assessments.where(date: Date.parse(date)).first
end

def find_file_group_assessment(date, location)
  file_group = FileGroup.find_by(external_file_location: location)
  file_group.assessments.where(date: Date.parse(date)).first
end