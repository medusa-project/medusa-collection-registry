And(/^I visit the static page '(.*)'$/) do |page|
  visit static_path(page: page)
end

Then(/^I should be on the static page '(.*)'$/) do |page|
  expect(current_path).to eq(static_path(page: page))
end