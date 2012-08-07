And /^I have production_units with fields:$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create :production_unit, hash
  end
end

When /^I go to the new production unit page$/ do
  visit new_production_unit_path
end

When /^I go to the production unit index page$/ do
  visit production_units_path
end

When /^I edit the production unit titled '(.*)'$/ do |title|
  visit edit_production_unit_path(ProductionUnit.find_by_title(title))
end

When /^I view the production unit titled '(.*)'$/ do |title|
  visit production_unit_path(ProductionUnit.find_by_title(title))
end

Then /^A production unit with the title '(.*)' should exist$/ do |title|
  ProductionUnit.find_by_title(title).should_not be_nil
end

Then /^I should see all production unit fields$/ do
  ['Address 1', 'Address 2', 'City', 'State', 'Zip', 'Phone number', 'Email', 'URL', 'Notes'].each do |field|
    step "I should see '#{field}'"
  end
end

Then /^I should see a table of production units$/ do
  page.should have_selector('#production_units')
end

And /^I click on '(.*)' in the production units table$/ do |action|
  within_table('production_units') do
    click_on action
  end
end

Then /^I should be on the production unit index page$/ do
  current_path.should == production_units_path
end

Then /^I should be on the view page for the production unit titled '(.*)'$/ do |title|
  current_path.should == production_unit_path(ProductionUnit.find_by_title(title))
end


Then /^I should be on the edit page for the production unit titled '(.*)'$/ do |title|
  current_path.should == edit_production_unit_path(ProductionUnit.find_by_title(title))
end

Then /^I should be on the production unit creation page$/ do
  current_path.should == new_production_unit_path
end