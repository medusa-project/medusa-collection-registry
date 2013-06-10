When /^I fill in fields:$/ do |table|
  complete_form_from_table(table)
end

And(/^I fill in fields for a scheduled event:$/) do |table|
  within('#scheduled-event-form') do
    complete_form_from_table(table)
  end
end

Then /^The field '(.*)' should be filled in with '(.*)'$/ do |field, value|
  find_field(field).value.should == value
end


When /^I press '(.*)'$/ do |button_name|
  click_button(button_name)
end

Then /^I should see '(.*)'$/ do |text|
  page.should have_content(text)
end

Then /^I should not see '(.*)'$/ do |text|
  page.should_not have_content(text)
end

And /^I should see all of:$/ do |table|
  table.headers.each do |header|
    step "I should see '#{header}'"
  end
end

And /^I should see none of:$/ do |table|
  table.headers.each do |header|
    step "I should not see '#{header}'"
  end
end

And /^I click on '(.*)'$/ do |link_name|
  click_on(link_name)
end

And /^I select '(.*)' from '(.*)'$/ do |value, label|
  select(value, :from => label)
end

And /^I check '(.*)'$/ do |string|
  check(string)
end

And /^I uncheck '(.*)'$/ do |string|
  uncheck(string)
end

And(/^I attach fixture file '(.*)' to '(.*)'$/) do |file, field|
  attach_file(field, File.join(Rails.root, 'features', 'fixtures', file))
end

def complete_form_from_table(table)
  table.raw.each do |row|
    fill_in(row.first, :with => row.last)
  end
end


