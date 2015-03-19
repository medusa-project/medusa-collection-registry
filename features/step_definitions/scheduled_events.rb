Then(/^the (.*) with (.*) '([^']*)' should have scheduled events with fields:$/) do |object_type, key, value, table|
  object = find_object(object_type, key, value)
  table.hashes.each do |hash|
    object.scheduled_events.find_by(hash).should be_truthy
  end
end

Given(/^the (.*) with (.*) '([^']*)' has scheduled events with fields:$/) do |object_type, key, value, table|
  object = find_object(object_type, key, value)
  table.hashes.each do |hash|
    object.scheduled_events.create(hash)
  end
end

Then(/^I should on the edit page for the scheduled event with key '([^']*)' and action date '([^']*)'$/) do |key, date|
  current_path.should == edit_scheduled_event_path(ScheduledEvent.find_by(key: key, action_date: date))
end

When(/^I edit the scheduled event with key '([^']*)' and action date '([^']*)'$/) do |key, date|
  visit edit_scheduled_event_path(ScheduledEvent.find_by(key: key, action_date: date))
end

Then(/^there should be no scheduled event having key '([^']*)' and action date '([^']*)'$/) do |key, date|
  ScheduledEvent.find_by(key: key, action_date: date).should == nil
end

