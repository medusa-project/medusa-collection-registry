Then /^the collection titled '(.*)' should have rights attached$/ do |title|
  Collection.find_by(title: title).rights_declaration.should_not be_nil
end

Then /^The file group with location '(.*)' for the collection titled '(.*)' should have rights attached$/ do |location, title|
  Collection.find_by(title: title).file_groups.detect do |file_group|
    file_group.external_file_location == location
  end.rights_declaration.should_not be_nil
end

Then /^The rights declaration for the collection titled '(.*)' should have rights basis '(.*)'$/ do |title, rights_basis|
  Collection.find_by(title: title).rights_declaration.rights_basis.should == rights_basis
end

Then /^I should see the rights declaration section$/ do
  page.should have_selector('#rights-declaration')
end

And(/^the (.*) with (.*) '(.*)' has (.*) rights$/) do |object_type, key, value, rights_type|
  klass = class_for_object_type(object_type)
  instance = klass.find_by(key.gsub(' ', '_') => value)
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