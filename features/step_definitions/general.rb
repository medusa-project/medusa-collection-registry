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
  page.save_screenshot(File.join(Rails.root, file), full: true)
end

And(/^I wait for (\d+) of '(.*)' to exist$/) do |count, class_name|
  klass = Kernel.const_get(class_name)
  while klass.count < count.to_i
    sleep 0.05
  end
end