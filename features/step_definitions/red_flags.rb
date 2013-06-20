Then(/^I should see a table of red flags$/) do
  page.should have_selector('table#red-flags-table')
end

And(/^I click on '(.*)' in the red flags table$/) do |link|
  within('table#red-flags-table') do
    click_on(link)
  end
end