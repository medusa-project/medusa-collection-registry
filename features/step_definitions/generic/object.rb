And /^there should be no (.*) with (.*) '([^']*)'$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key => value)).to be_nil
end

Then /^a (.*) with (.*) '([^']*)' should exist$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key.gsub(' ', '_') => value)).not_to be_nil
end

Then /^the (.*)s? with fields should exist:?$/ do |object_type, table|
  klass = class_for_object_type(object_type)
  all = klass.all.to_a
  table.hashes.each do |hash|
    expect(klass.find_by(hash)).not_to be_nil
  end
end

#As conceived here only works for non-polymorphic associations, and of course with appropriate factory naming conventions
And /^the (.*) with (.*) '([^']*)' has associated (.*) with field (.*):$/ do |base_object_type, base_key, base_value, association_name, association_key, table|
  association_name = association_name.gsub(' ', '_')
  base = step "the #{base_object_type} with #{base_key} '#{base_value}' exists"
  association = base.class.reflect_on_association(association_name.singularize) || base.class.reflect_on_association(association_name.pluralize)
  association_factory_name = association.class_name.underscore
  table.headers.each do |child_value|
    base.send(association.name) << (step "the #{association_factory_name} with #{association_key.gsub(' ', '_').singularize} '#{child_value}' exists")
  end
end

And /^the (.*) with (.*) '([^']*)' has child (.*) with field (.*):$/ do |parent_object_type, parent_key, parent_value, child_object_type, child_key, table|
  parent = step "the #{parent_object_type} with #{parent_key} '#{parent_value}' exists"
  table.headers.each do |child_value|
    parent.send(child_object_type.gsub(' ', '_').pluralize) << (step "the #{child_object_type.gsub(' ', '_').singularize} with #{child_key.gsub(' ', '_').singularize} '#{child_value}' exists")
  end
end

And /^the (.*) with (.*) '([^']*)' has child (.*) with fields:$/ do |parent_object_type, parent_key, parent_value, child_object_type, table|
  parent = step "the #{parent_object_type} with #{parent_key} '#{parent_value}' exists"
  table.hashes.each do |child_hash|
    parent.send(child_object_type.gsub(' ', '_').pluralize) << FactoryBot.create(child_object_type.gsub(' ', '_').singularize, child_hash)
  end
end

And /^the (.*) with (.*) '([^']*)' should have (\d+) (.*) with (.*) '([^']*)'$/ do |parent_object_type, parent_key, parent_value, count, child_object_type, child_key, child_value|
  find_object(parent_object_type, parent_key, parent_value).send(child_object_type.gsub(' ', '_').pluralize).where(child_key.gsub(' ', '_') => child_value).count.should == count.to_i
end

And /^the (.*) with (.*) '([^']*)' should have (\d+) ([^']*)$/ do |parent_object_type, parent_key, parent_value, count, child_object_type|
  find_object(parent_object_type, parent_key, parent_value).send(child_object_type.gsub(' ', '_').pluralize).count.should == count.to_i
end


And /^the (.*) with (.*) '([^']*)' exists$/ do |object_type, key, value|
  klass = class_for_object_type(object_type) rescue nil
  underscored_key = key.gsub(' ', '_')
  if klass
    klass.find_by(underscored_key => value) || FactoryBot.create(object_type.gsub(' ', '_'), underscored_key => value)
  else
    FactoryBot.create(object_type.gsub(' ', '_'), underscored_key => value)
  end

end

And /^each (.*) with (.*) exists:$/ do |object_type, key, table|
  table.headers.each do |header|
    step "the #{object_type} with #{key} '#{header}' exists"
  end
end

And /^every (.*) with fields exists:$/ do |object_type, table|
  table.hashes.each do |hash|
    FactoryBot.create(object_type.gsub(' ', '_'), hash)
  end
end

Then /^each (.*) with (.*) should exist:$/ do |object_type, key, table|
  table.headers.each do |header|
    step "a #{object_type} with #{key} '#{header}' should exist"
  end
end

When(/^I destroy the (.*) with (.*) '([^']*)'$/) do |object_type, key, value|
  find_object(object_type, key, value).destroy
end

And /^the (.*) with (.*) '([^']*)' should have associated (.*) with field (.*):$/ do |parent_object_type, parent_key, parent_value, child_object_type, child_key, table|
  parent_object = find_object(parent_object_type, parent_key, parent_value)
  table.headers.each do |value|
    expect(parent_object.send(child_object_type.gsub(' ', '_').pluralize).find_by(child_key.gsub(' ', '_') => value)).to be_truthy
  end
end

And /^the (.*) with (.*) '([^']*)' should not have associated (.*) with field (.*):$/ do |parent_object_type, parent_key, parent_value, child_object_type, child_key, table|
  parent_object = find_object(parent_object_type, parent_key, parent_value)
  table.headers.each do |value|
    expect(parent_object.send(child_object_type.gsub(' ', '_').pluralize).find_by(child_key.gsub(' ', '_') => value)).to be_falsey
  end
end
