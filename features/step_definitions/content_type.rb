Then /^There should be standard default content types$/ do
  ['digitized book', 'metadata', 'born digital images'].each do |name|
    ContentType.find_by_name(name).should_not be_nil
  end
end