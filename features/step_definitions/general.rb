Given /^PENDING$/ do
  pending
end

Given /^Nothing$/ do
  #do nothing - just to explicitly say that no Given is really required
end

#TODO - this doesn't work as is, and I'm not sure it is generally possible via Capybara
Then(/^the response code should be (\d+)$/) do |code|
  pending
  response.status.to_s.should == code
end