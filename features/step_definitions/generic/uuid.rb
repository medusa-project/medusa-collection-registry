And(/^the uuid of the (.*) with (.*) '([^']*)' is '([^']*)'$/) do |object_type, key, value, uuid|
  object = find_object(object_type, key, value)
  object.uuid = uuid
  object.save!
end

When(/^I visit the object with uuid '([^']*)'$/) do |uuid|
  visit uuid_path(uuid)
end

And /^I should see the uuid of the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  steps "Then I should see '#{find_object(object_type, key, value).uuid}'"
end

Then /^The (.*) with (.*) '([^']*)' should have a valid uuid$/ do |object_type, key, value|
  Utils::Luhn.verify(find_object(object_type, key, value).uuid).should be_truthy
end