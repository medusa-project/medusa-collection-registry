Then(/^I should be on the search page$/) do
  current_path.should == new_search_path
end

And(/^I go to the search page$/) do
  visit new_search_path
end

Then(/^I should see a table of cfs files with (\d+) rows?$/) do |count|
  expect(page).to have_selector('#search_results')
  within('#search_results') do
    expect(page).to have_css('tbody tr', :count => count.to_i)
  end
end

And(/^I try to submit a filename search$/) do
  self.send(:post, filename_searches_path)
end