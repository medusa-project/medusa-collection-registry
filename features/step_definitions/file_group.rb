And /^the collection titled '(.*)' has file groups with fields:$/ do |title, table|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  table.hashes.each do |hash|
    FactoryGirl.create(:file_group, hash.merge({:collection => collection}))
  end
end

And /^the collection titled '(.*)' should have (\d+) file group$/ do |title, count|
  Collection.find_by_title(title).file_groups.count.should == count.to_i
end

Then /^I should see the file group id for the file group with location '(.*)' in the file group collection table$/ do |location|
  id = FileGroup.find_by_external_file_location(location).id
  within_table('file_groups') do
    step "I should see '#{id}'"
  end
end

And /^I should not see '(.*)' in the related file groups section$/ do |string|
  within('#related-file-groups') do
    step "I should not see '#{string}'"
  end
end

Then /^I should be on the view page for the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  current_path.should == polymorphic_path(find_file_group(title, location))
end

And /^I should be on the view page for the file group named '(.*)'$/ do |name|
  current_path.should == polymorphic_path(FileGroup.find_by_name(name))
end

Then /^I should be on the edit page for the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  current_path.should == edit_polymorphic_path(find_file_group(title, location))
end

Then(/^I should be on the edit page for the file group named '(.*)'$/) do |name|
  current_path.should == edit_polymorphic_path(FileGroup.find_by_name(name))
end

When /^I edit the file group named '(.*)'$/ do |name|
  visit edit_polymorphic_path(FileGroup.find_by_name(name))
end

When /^I view the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  visit polymorphic_path(find_file_group(title, location))
end

When /^I view the file group named '(.*)'$/ do |name|
  visit polymorphic_path(FileGroup.find_by_name(name))
end

When /^I edit the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  visit edit_polymorphic_path(find_file_group(title, location))
end

Given /^I am editing a file group$/ do
  visit edit_polymorphic_path(FactoryGirl.create(:file_group))
end

And /^The collection titled '(.*)' should not have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:external_file_location => location).should be_empty
end

And /^The collection titled '(.*)' should have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:external_file_location => location).should_not be_empty
end

And /^I fill in file group form date '(\d+)\-(\d+)\-(\d+)'$/ do |year, month, day|
  fill_in_date_select(year, month, day, 'file_group_last_access_date')
end

And /^The file group with location '(.*)' for the collection titled '(.*)' should have producer titled '(.*)'$/ do |location, collection_title, producer_title|
  find_file_group(collection_title, location).producer.title.should == producer_title
end

Given /^The file group with location '(.*)' for the collection titled '(.*)' has producer titled '(.*)'$/ do |location, collection_title, producer_title|
  file_group = find_file_group(collection_title, location)
  file_group.producer = Producer.find_by_title(producer_title)
  file_group.save
end

Given /^The file group with location '(.*)' has file type '(.*)'$/ do |location, file_type|
  file_group = FileGroup.find_by_external_file_location(location)
  file_group.file_type = FileType.find_by_name(file_type)
  file_group.save
end

Given /^The file group with location '(.*)' has a root directory$/ do |location|
  file_group = FileGroup.find_by_external_file_location(location)
  file_group.collection.make_file_group_root("file_group_#{file_group.id}", file_group)
end

And /^the file group named '(.*)' has a root directory named '(.*)'$/ do |file_group_name, directory_name|
  file_group = FileGroup.find_by_name(file_group_name)
  file_group.collection.make_file_group_root(directory_name, file_group)
end

Then /^I should be on the view page for the root directory for the file group with location '(.*)'$/ do |location|
  file_group = FileGroup.find_by_external_file_location(location)
  current_path.should == directory_path(file_group.root_directory)
end

And /^the file groups named '(.*)' and '(.*)' are related$/ do |name_1, name_2|
  file_group_1 = FileGroup.find_by_name(name_1)
  file_group_2 = FileGroup.find_by_name(name_2)
  file_group_1.related_file_groups << file_group_2
end

And /^the file groups named '(.*)' and '(.*)' are related with note '(.*)'$/ do |name_1, name_2, note|
  file_group_1 = FileGroup.find_by_name(name_1)
  file_group_2 = FileGroup.find_by_name(name_2)
  file_group_1.related_file_groups << file_group_2
  relation = RelatedFileGroupJoin.where(:file_group_id => file_group_1.id, :related_file_group_id => file_group_2.id).first
  relation.note = note
  relation.save!
end

And /^the file groups named '(.*)' and '(.*)' should be related$/ do |name_1, name_2|
  file_group_1 = FileGroup.find_by_name(name_1)
  file_group_2 = FileGroup.find_by_name(name_2)
  file_group_1.related_file_groups.include?(file_group_2).should be_true
  file_group_2.related_file_groups.include?(file_group_1).should be_true
end

And /^the file groups named '(.*)' and '(.*)' should not be related$/ do |name_1, name_2|
  file_group_1 = FileGroup.find_by_name(name_1)
  file_group_2 = FileGroup.find_by_name(name_2)
  file_group_1.related_file_groups.include?(file_group_2).should be_false
  file_group_2.related_file_groups.include?(file_group_1).should be_false
end

And /^the file groups named '(.*)' and '(.*)' should have relation note '(.*)'$/ do |name_1, name_2, note|
  FileGroup.find_by_name(name_1).relation_note(FileGroup.find_by_name(name_2)).should == note
  FileGroup.find_by_name(name_2).relation_note(FileGroup.find_by_name(name_1)).should == note
end

And /^the file group named '(.*)' should have (\d+) events?$/ do |name, number|
  FileGroup.find_by_name(name).events.length.should == number.to_i
end

And(/^the cfs root for the file group named '(.*)' should be nil$/) do |name|
  FileGroup.find_by_name(name).cfs_root.should be_nil
end

And(/^the file group named '(.*)' has an assessment named '(.*)'$/) do |file_group_name, assessment_name|
  file_group = FileGroup.find_by_name(file_group_name)
  FactoryGirl.create(:assessment, :name => assessment_name, :assessable_id => file_group.id, :assessable_type => 'FileGroup')
end

private

def find_file_group(collection_title, location)
  collection = Collection.find_by_title(collection_title)
  collection.file_groups.where(:external_file_location => location).first
end