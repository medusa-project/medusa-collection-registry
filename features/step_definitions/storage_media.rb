Then /^There should be standard default storage media$/ do
  #just test a sample
  ['CD-Rom', 'DVD', 'file server'].each do |name|
    StorageMedium.find_by_name(name).should_not be_nil
  end
end