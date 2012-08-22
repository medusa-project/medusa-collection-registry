And /^there are object types named:$/ do |table|
  table.headers.each do |header|
    FactoryGirl.create(:object_type, :name => header) unless ObjectType.find_by_name(header)
  end
end

Then /^there should be object types named:$/ do |table|
  table.headers.each do |name|
    step "there should be an object type named '#{name}'"
  end
end

Then /^there should be an object type named '(.*)'$/ do |name|
  ObjectType.find_by_name(name).should_not be_nil
end