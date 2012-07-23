When /^I fill in fields:$/ do |table|
  table.hashes.each do |hash|
    fill_in(hash[:field], :with => hash[:value])
  end
end