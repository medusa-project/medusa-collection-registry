Then(/^I should see a search table of (.*) with (\d+) rows?$/) do |type, count|
  selector = "#search_#{type.gsub(' ', '_')}"
  expect(page).to have_selector(selector)
  within(selector) do
    expect(page).to have_css('tbody tr', count: count.to_i)
  end
end

And(/^I try to submit a filename search$/) do
  self.send(:post, filename_searches_path)
end

Then(/^there is no filename search box$/) do
  expect(page).not_to have_css('#filename_search')
end

And(/^I do a search for '([^']*)'$/) do |search_string|
  click_on('show_search')
  within('#search') do
    fill_in('Search query', with: search_string)
    click_on('search_submit')
  end
end