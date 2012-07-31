And /^There should be a person with net ID '(.*)'$/ do |net_id|
  Person.find_by_net_id(net_id).should_not be_nil
end