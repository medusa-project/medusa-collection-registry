And /^I go to the site home$/ do
  visit '/'
end

Then /^I should see a global navigation bar$/ do
  page.should have_selector('#global-navigation')
end

When /^I click on '(.*)' in the global navigation bar$/ do |name|
  within('#global-navigation') {click_link name}
end

Then /^There should be an external link '(.*)' to the UIUC Net ID search$/ do |net_id|
  page.has_link?(net_id, :href => "http://illinois.edu/ds/search?skinId=0&search_type=userid&search=#{net_id}")
end