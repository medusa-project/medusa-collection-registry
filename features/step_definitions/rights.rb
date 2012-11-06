Then /^the collection titled '(.*)' should have rights attached$/ do |title|
  Collection.find_by_title(title).rights_declaration.should_not be_nil
end

Then /^The file group with location '(.*)' for the collection titled '(.*)' should have rights attached$/ do |location, title|
  Collection.find_by_title(title).file_groups.detect do |file_group|
    file_group.file_location == location
  end.rights_declaration.should_not be_nil
end