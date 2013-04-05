Then /^I should be on the dashboard page$/ do
  current_path.should == dashboard_path
end

And /^The dashboard should have a red flags section$/ do
  page.should have_selector('#red-flags')
end


And /^The dashboard should have a file statistics section$/ do
  page.should have_selector('#file-statistics')
end

And /^The dashboard should have a running processes section$/ do
  page.should have_selector('#running-processes')
end

Then /^The dashboard should have a storage overview section$/ do
  page.should have_selector('#storage-overview')
end

When /^I go to the dashboard$/ do
  visit dashboard_path
end

Then /^I should see the bit & object preservation content_type statistics$/ do
  page.should have_selector('table#file_stats')
end

And /^I should see the bit & object preservation summary file statistics$/ do
  page.should have_selector('table#file_stats_summary')
end

Then /^I should see a bit preservation content_type table$/ do
  page.should have_selector('table#file_stats_bits')
end

Then /^I should see an object preservation content_type table$/ do
  page.should have_selector('table#file_stats_objects')
end

Then /^show me the page$/ do
  save_and_open_page
end