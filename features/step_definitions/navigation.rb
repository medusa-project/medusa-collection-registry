And /^I go to the site home$/ do
  visit '/'
end

Then /^I should see a global navigation bar$/ do
  page.should have_selector('#global-navigation')
end

When /^I click on '(.*)' in the global navigation bar$/ do |name|
  within('#global-navigation') {click_link name}
end