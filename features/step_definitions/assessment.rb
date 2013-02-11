And /^the collection titled '(.*)' has assessments with fields:$/ do |title, table|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, title => title)
  table.hashes.each do |hash|
    FactoryGirl.create(:assessment, hash.merge({:assessable => collection}))
  end
end

Then /^I should be on the view page for the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  current_path.should == assessment_path(find_assessment(date, title))
end

When /^I view the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  visit assessment_path(find_assessment(date, title))
end

When /^I edit the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
    visit edit_assessment_path(find_assessment(date, title))
end

Then /^I should be on the edit page for the assessment with date '(.*)' for the collection titled '(.*)'$/ do |date, title|
  current_path.should == edit_assessment_path(find_assessment(date, title))
end

And /^The collection titled '(.*)' should not have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should be_nil
end

And /^The collection titled '(.*)' should have an assessment with date '(.*)'$/ do |title, date|
  find_assessment(date, title).should_not be_nil
end

private

def find_assessment(date, collection_title)
  collection = Collection.find_by_title(collection_title)
  collection.assessments.where(:date => Date.parse(date)).first
end