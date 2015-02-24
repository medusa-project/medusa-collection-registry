Then(/^(.*) is unauthorized to update the static page '(.*)'$/) do |user_type, key|
  step "I am logged in as #{user_type}"
  put static_page_path(key: key)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end