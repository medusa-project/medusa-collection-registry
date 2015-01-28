Then(/^I should be on the cfs files page for the (.*) with (.*) '(.*)'$/) do |object_type, key, value|
  expect(current_path).to eq(specific_object_path(object_type, key, value, 'cfs_files'))
end

And(/^I view cfs files for the content type with name '(.*)'$/) do |content_type_name|
  visit (specific_object_path('content type', 'name', content_type_name, 'cfs_files'))
end