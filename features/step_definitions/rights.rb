Then /^the (.*) with (.*) '([^']*)' should have rights attached$/ do |object_type, key, value|
  find_object(object_type, key, value).rights_declaration.should be_truthy
end

Then /^The rights declaration for the (.*) with (.*) '([^']*)' should have rights basis '([^']*)'$/ do |object_type, key, value, rights_basis|
  find_object(object_type, key, value).rights_declaration.rights_basis.should == rights_basis
end

Then /^I should see the rights declaration section$/ do
  page.should have_selector('#rights-declaration')
end
