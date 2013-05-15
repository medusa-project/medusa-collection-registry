Then(/^I should see a table of red flags$/) do
  page.should have_selector('table#red-flags')
end