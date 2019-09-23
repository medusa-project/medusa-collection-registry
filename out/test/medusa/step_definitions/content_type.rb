Then(/^I should be on the cfs files page for the (.*) with (.*) '([^']*)'$/) do |object_type, key, value|
  expect(current_path).to eq(specific_object_path(object_type, key, value, prefix: 'cfs_files'))
end
