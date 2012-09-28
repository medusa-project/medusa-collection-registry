When /^I fill in fields:$/ do |table|
  table.raw.each do |row|
    fill_in(row.first, :with => row.last)
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








