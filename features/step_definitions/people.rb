And /^There should be a person with email '(.*)'$/ do |email|
  Person.where(email: email).first.should_not be_nil
end
