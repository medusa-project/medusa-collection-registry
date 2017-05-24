When /^I go to the (.*) index page$/ do |object_type|
  visit generic_collection_path(object_type)
end

Then /^I should be on the (.*) index page$/ do |object_type|
  expect(current_path).to eq(generic_collection_path(object_type))
end

When /^I view the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  visit generic_object_path(object_type, key, value)
end

When /^I view JSON for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  visit generic_object_path(object_type, key, value, format: 'json')
end

Then /^I should be on the view page for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  expect(current_path).to eq(generic_object_path(object_type, key, value))
end

Then(/^I should be on the view page for the (.*) with (.*) '([^']*)' in '([^']*)' format$/) do |object_type, key, value, format|
  expect(current_path).to eq(generic_object_path(object_type, key, value, format: format))
end

When /^I edit the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  visit generic_object_path(object_type, key, value, prefix: 'edit')
end

Then /^I should be on the edit page for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  expect(current_path).to eq(generic_object_path(object_type, key, value, prefix: 'edit'))
end

Then /^I should be on the update page for the (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  expect(current_path).to eq(generic_object_path(object_type, key, value))
end

Then /^I should be on the new (.*) page$/ do |object_type|
  expect(current_path).to eq(self.send("new_#{object_type.gsub(' ', '_')}_path"))
end

When /^I go to the new (.*) page$/ do |object_type|
  visit self.send("new_#{object_type.gsub(' ', '_')}_path")
end

Then /^I should be on the create (.*) page$/ do |object_type|
  expect(current_path).to eq(generic_collection_path(object_type))
end

Given /^I am editing an? (.*)$/ do |object_type|
  visit self.send('edit_polymorphic_path', FactoryGirl.create(object_type.gsub(' ', '_')))
end

def generic_collection_path(object_type, prefix: nil)
  path_prefix = prefix ? "#{prefix}_" : ''
  self.send(:"#{path_prefix}#{object_type.gsub(' ', '_').pluralize}_path")
end

def class_for_object_type(object_type)
  Kernel.const_get(object_type.gsub(' ', '_').camelize.singularize)
end

def find_object(object_type, key, value)
  klass = class_for_object_type(object_type)
  klass.find_by(key.gsub(' ', '_') => value)
end

def find_or_create_object(object_type, key, value)
  find_object(object_type, key,value) || FactoryGirl.create(object_type.gsub(' ', '_'), key => value)
end

#uses polymorphic path in conjunction with the object to find the path - will usually work, but not for non-standard prefixes
def generic_object_path(object_type, key, value, prefix: nil, format: nil)
  path_prefix = prefix ? "#{prefix}_" : ''
  self.send(:"#{path_prefix}polymorphic_path", find_object(object_type, key, value), format: format)
end

#uses the actual object type to find the path, needed for some prefixes
def specific_object_path(object_type, key, value, prefix: nil)
  path_prefix = prefix ? "#{prefix}_" : ''
  self.send(:"#{path_prefix}#{object_type.gsub(' ', '_')}_path", find_object(object_type, key, value))
end
