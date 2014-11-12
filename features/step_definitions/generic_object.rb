And /^there should be no (.*) with (.*) '(.*)'$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key => value)).to be_nil
end

Then /^a (.*) with (.*) '(.*)' should exist$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key.gsub(' ', '_') => value)).not_to be_nil
end

And /^the (.*) with (.*) '(.*)' has child (.*) with field (.*):$/ do |parent_object_type, parent_key, parent_value, child_object_type, child_key, table|
  parent = step "the #{parent_object_type} with #{parent_key} '#{parent_value}' exists"
  table.headers.each do |child_value|
    parent.send(child_object_type.gsub(' ', '_').pluralize) << (step "the #{child_object_type.gsub(' ', '_').singularize} with #{child_key.gsub(' ', '_').singularize} '#{child_value}' exists")
  end
end

And /^the (.*) with (.*) '(.*)' has child (.*) with fields:$/ do |parent_object_type, parent_key, parent_value, child_object_type, table|
  parent = step "the #{parent_object_type} with #{parent_key} '#{parent_value}' exists"
  table.hashes.each do |child_hash|
    parent.send(child_object_type.gsub(' ', '_').pluralize) << FactoryGirl.create(child_object_type.gsub(' ', '_').singularize, child_hash)
  end
end

And /^the (.*) with (.*) '(.*)' should have (\d+) (.*) with (.*) '(.*)'$/ do |parent_object_type, parent_key, parent_value, count, child_object_type, child_key, child_value|
  parent_klass = class_for_object_type(parent_object_type)
  parent_klass.find_by(parent_key.gsub(' ', '_') => parent_value).send(child_object_type.gsub(' ', '_').pluralize)
    .where(child_key.gsub(' ', '_') => child_value).count.should == count.to_i
end

And /^the (.*) with (.*) '(.*)' should have (\d+) ([^']*)$/ do |parent_object_type, parent_key, parent_value, count, child_object_type|
  parent_klass = class_for_object_type(parent_object_type)
  parent_klass.find_by(parent_key.gsub(' ', '_') => parent_value).send(child_object_type.gsub(' ', '_').pluralize)
    .count.should == count.to_i
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

And /^every (.*) with fields exists:$/ do |object_type, table|
  table.hashes.each do |hash|
    FactoryGirl.create object_type.gsub(' ', '_'), hash
  end
end


Then /^each (.*) with (.*) should exist:$/ do |object_type, key, table|
  table.headers.each do |header|
    step "a #{object_type} with #{key} '#{header}' should exist"
  end
end

When(/^I destroy the (.*) with (.*) '(.*)'$/) do |object_type, key, value|
  klass = class_for_object_type(object_type)
  underscored_key = key.gsub(' ', '_')
  klass.find_by(underscored_key => value).destroy
end