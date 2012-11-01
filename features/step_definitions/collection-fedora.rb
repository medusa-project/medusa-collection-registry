Then /^The collection titled '(.*)' should have a matching collection record in fedora$/ do |title|
  collection = Collection.find_by_title(title)
  steps "Then There should be a fedora object with pid '#{collection.medusa_pid}'"
  collection.fedora_mods_datastream.content.should == collection.to_mods
end

Then /^The collection titled '(.*)' should have (\d+) MODS versions? in fedora$/ do |title, count|
  collection = Collection.find_by_title(title)
  collection.fedora_mods_datastream.versions.count.should == count.to_i
end

Then /^There should be a fedora object with pid '(.*)'$/ do |pid|
  ActiveFedora::Base.exists?(pid).should be_true
end

Then /^There should be no fedora object with pid '(.*)'$/ do |pid|
  ActiveFedora::Base.exists?(pid).should be_false
end