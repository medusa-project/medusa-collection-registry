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