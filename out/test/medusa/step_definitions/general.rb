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
  time = 0
  timeout = 5
  interval = 0.05
  while klass.count < count.to_i and time < timeout
    time += interval
    sleep interval
  end
end

And /^I press escape$/ do
  first('body').send_keys(:escape)
end

And(/^I accept the alert$/) do
  page.accept_alert
end