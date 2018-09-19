When /^I fill in fields:$/ do |table|
  complete_form_from_table(table)
end

Then /^The field '([^']*)' should be filled in with '([^']*)'$/ do |field, value|
  find_field(field).value.should == value
end


When /^I press '([^']*)'$/ do |button_name|
  click_button(button_name)
end

Then /^I should see '(.*)'$/ do |text|
  page.should have_content(text)
end

Then /^I should not see '([^']*)'$/ do |text|
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

And /^I click on '([^']*)'$/ do |link_name|
  click_on(link_name)
end

And(/^I click on and confirm '(.*)'$/) do |link_name|
  accept_confirm do
    click_on(link_name)
  end
end

And(/^I click on '(.*)' expecting an alert '(.*)'$/) do |link_name, alert_text|
  accept_alert(alert_text) do
    click_on(link_name)
  end
end

And /^I click consecutively on:$/ do |table|
  table.headers.each {|header| click_on(header) ; sleep 0.5}
end

And /^within '(.*)' I click on '(.*)'$/ do |locator, link_name|
  within(locator) {click_on(link_name)}
end

And /^I click on '([^']*)' and delayed jobs are run$/ do |link_name|
  step "I click on '#{link_name}'"
  step 'delayed jobs are run'
end

Then(/^I should not see a '(.*)' link$/) do |text|
  expect(page).to have_no_link(text)
end

And /^I select '([^']*)' from '([^']*)'$/ do |value, label|
  select(value, from: label)
end

And /^I check '([^']*)'$/ do |string|
  check(string)
end

And /^I check all of:$/ do |table|
  table.headers.each {|header| check(header)}
end

And /^I uncheck '([^']*)'$/ do |string|
  uncheck(string)
end

And(/^I choose '([^']*)'$/) do |string|
  choose(string)
end

Then(/^the checkbox '([^']*)' should be disabled and unchecked$/) do |label|
  expect(page).to have_unchecked_field(label, disabled: true)
end

Then(/^the text area '([^']*)' should be disabled$/) do |label|
  expect(page).to have_field(label, disabled: true)
end

Then(/^the text area '([^']*)' should be enabled$/) do |label|
  expect(page).to have_field(label, disabled: false)
end

And(/^I attach fixture file '([^']*)' to '([^']*)'$/) do |file, field|
  attach_file(field, File.join(Rails.root, 'features', 'fixtures', file))
end

And(/^there should be inputs with values:$/) do |table|
  table.headers.each do |value|
    expect(page).to have_xpath("//input[@value='#{value}']")
  end
end

And(/^there should not be inputs with values:$/) do |table|
  table.headers.each do |value|
    expect(page).not_to have_xpath("//input[@value='#{value}']")
  end
end

def complete_form_from_table(table)
  table.raw.each do |row|
    fill_in(row.first, with: row.last)
  end
end
