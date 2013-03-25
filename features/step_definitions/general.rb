Given /^PENDING$/ do
  pending
end

Given /^Nothing$/ do
  #do nothing - just to explicitly say that no Given is really required
end

Then(/^the response code should be (\d+)$/) do |code|
  page.response.code.to_s.should == code
end