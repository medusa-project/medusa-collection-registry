When /^I request JSON for the file group with location '(.*)'$/ do |location|
  visit file_group_path(FileGroup.find_by_file_location(location), :format => 'json')
end