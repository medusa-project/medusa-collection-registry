And /^the (.*) with (.*) '([^']*)' has an event with key '([^']*)' performed by '([^']*)'$/ do |object_type, key, value, event_key, email|
  find_or_create_object(object_type, key, value).events.create(key: event_key, actor_email: email, date: Date.today)
end

Then /^the (.*) with (.*) '([^']*)' should have an event with key '([^']*)' performed by '([^']*)'$/ do |object_type, key, value, event_key, email|
  find_object(object_type, key, value).events.find_by(key: event_key, actor_email: email).should be_truthy
end

And(/^the (.*) with (.*) '([^']*)' has events with fields:$/) do |object_type, key, value, table|
  object = find_or_create_object(object_type, key, value)
  table.hashes.each do |hash|
    FactoryGirl.create(:event, hash.merge(eventable: object))
  end
end

Then(/^the (.*) with (.*) '([^']*)' should have events with fields:$/) do |object_type, key, value, table|
  object = find_object(object_type, key, value)
  table.hashes.each do |hash|
    object.events.find_by(hash).should be_truthy
  end
end

Then(/^the (.*) with (.*) '([^']*)' should have cascadable events with fields:$/) do |object_type, key, value, table|
  object = find_object(object_type, key, value)
  table.hashes.each do |hash|
    object.cascaded_events.detect do |event|
      hash.keys.all? do |hash_key|
        event.send(hash_key) == hash[hash_key]
      end
    end.should be_truthy
  end
end

When(/^I view events for the (.*) with (.*) '([^']*)'$/) do |object_type, key, value|
  visit specific_object_path(object_type, key, value, 'events')
end

Then /^I should be viewing events for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  expect(current_path).to eq(specific_object_path(object_type, key, value, 'events'))
end

Then /^a (.*) is unauthorized to create an event for the file group titled '([^']*)'$/ do |user_type, title|
  if user_type == 'visitor'
    rack_login('a visitor')
    expected_path = unauthorized_path
  else
    expected_path = login_path
  end
  post events_path(eventable_type: 'FileGroup', eventable_id: FileGroup.find_by(title: title))
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end
