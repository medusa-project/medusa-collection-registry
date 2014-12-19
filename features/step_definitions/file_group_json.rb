When /^I request JSON for the file group with location '(.*)'$/ do |location|
  visit polymorphic_path(FileGroup.find_by(external_file_location: location), format: 'json')
end