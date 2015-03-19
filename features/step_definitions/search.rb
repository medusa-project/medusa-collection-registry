Then(/^I should see a table of cfs files with (\d+) rows?$/) do |count|
  expect(page).to have_selector('#cfs_files')
  within('#cfs_files') do
    expect(page).to have_css('tbody tr', count: count.to_i)
  end
end

And(/^I try to submit a filename search$/) do
  self.send(:post, filename_searches_path)
end

Then(/^there is no filename search box$/) do
  expect(page).not_to have_css('#filename_search')
end

And(/^I do a filename search for '([^']*)'$/) do |search_string|
  within('#filename_search') do
    fill_in('Search file name', with: search_string)
    click_on('filename_search_submit')
  end
end