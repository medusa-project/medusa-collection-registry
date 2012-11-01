Then /^The collection titled '(.*)' should have a matching collection record in fedora$/ do |title|
  collection = Collection.find_by_title(title)
  ActiveFedora::Base.exists?(collection.medusa_pid).should be_true
  collection.fedora_mods_datastream.content.should == collection.to_mods
end

Then /^The collection titled '(.*)' should have (\d+) MODS versions? in fedora$/ do |title, count|
  collection = Collection.find_by_title(title)
  collection.fedora_mods_datastream.versions.count.should == count.to_i
end