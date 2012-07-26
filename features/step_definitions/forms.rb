When /^I fill in fields:$/ do |table|
  table.hashes.each do |hash|
    fill_in(hash[:field], :with => hash[:value])
  end
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

And /^I click on '(.*)'$/ do |link_name|
  click_link(link_name)
end





