Then /^the (.*) with (.*) '([^']*)' should have rights attached$/ do |object_type, key, value|
  find_object(object_type, key, value).rights_declaration.should be_truthy
end

Then /^The rights declaration for the (.*) with (.*) '([^']*)' should have rights basis '([^']*)'$/ do |object_type, key, value, rights_basis|
  find_object(object_type, key, value).rights_declaration.rights_basis.should == rights_basis
end

Then /^I should see the rights declaration section$/ do
  page.should have_selector('#rights-declaration')
end

And(/^the (.*) with (.*) '([^']*)' has (.*) rights$/) do |object_type, key, value, rights_type|
  instance = find_object(object_type, key, value)
  rights_declaration =
      if instance.respond_to?(:rights_declaration)
        instance.rights_declaration
      elsif instance.respond_to?(:file_group)
        instance.file_group.rights_declaration
      end
  rights_declaration.access_restrictions =
      case rights_type
        when 'public'
          'DISSEMINATE'
        when 'private'
          'DISSEMINATE/DISALLOW'
        else
          raise Runtime Error, 'Unrecognized rights type'
      end
  rights_declaration.save!
end