And /^there should be no (.*) with (.*) '(.*)'$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key => value)).to be_nil
end

Then /^a (.*) with (.*) '(.*)' should exist$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key.gsub(' ', '_') => value)).not_to be_nil
end

And /^the (.*) with (.*) '(.*)' exists$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  underscored_key = key.gsub(' ', '_')
  klass.find_by(underscored_key => value) || FactoryGirl.create(object_type.gsub(' ', '_'), underscored_key => value)
end

And /^each (.*) with (.*) exists:$/ do |object_type, key, table|
 table.headers.each do |header|
   step "the #{object_type} with #{key} '#{header}' exists"
 end
end

Then /^each (.*) with (.*) should exist:$/ do |object_type, key, table|
  table.headers.each do |header|
    step "a #{object_type} with #{key} '#{header}' should exist"
  end
end