And /^the directory named '(.*)' has bit files with fields:$/ do |name, table|
  directory = Directory.find_by_name(name)
  table.hashes.each do |hash|
    BitFile.create(hash.merge(:directory_id => directory.id))
  end
end

When /^I request JSON for the bit file named '(.*)'$/ do |name|
  visit file_path(BitFile.find_by_name(name), :format => 'json')
end