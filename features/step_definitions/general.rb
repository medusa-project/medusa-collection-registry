Given /^PENDING$/ do
  pending
end

Given /^Nothing$/ do
  #do nothing - just to explicitly say that no Given is really required
end

When /^I wait ([\d|\.]+) seconds?$/ do |seconds|
  sleep seconds.to_f
end

And(/^I screenshot to '(.*)'$/) do |file|
  page.save_screenshot(file, full: true)
end