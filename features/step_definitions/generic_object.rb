And /^There should be no (.*) with (.*) '(.*)'$/ do |object_type, key, value|
  klass = class_for_object_type(object_type)
  expect(klass.find_by(key => value)).to be_nil
end
