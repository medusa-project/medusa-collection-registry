And /^there are resource types named:$/ do |table|
  table.headers.each do |header|
    FactoryGirl.create(:resource_type, :name => header) unless ResourceType.find_by_name(header)
  end
end

Then /^there should be resource types named:$/ do |table|
  table.headers.each do |name|
    step "there should be an resource type named '#{name}'"
  end
end

Then /^there should be an resource type named '(.*)'$/ do |name|
  ResourceType.find_by_name(name).should_not be_nil
end