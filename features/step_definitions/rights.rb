Then /^the collection titled '(.*)' should have rights attached$/ do |title|
  Collection.find_by_title(title).rights_declaration.should_not be_nil
end

Then /^The file group with location '(.*)' for the collection titled '(.*)' should have rights attached$/ do |location, title|
  Collection.find_by_title(title).file_groups.detect do |file_group|
    file_group.file_location == location
  end.rights_declaration.should_not be_nil
end

Then /^The rights declaration for the collection titled '(.*)' should have rights basis '(.*)'$/ do |title, rights_basis|
  Collection.find_by_title(title).rights_declaration.rights_basis.should == rights_basis
end

Then /^I should see the rights declaration section$/ do
  page.should have_selector('#rights-declaration')
end