And /^the collection titled '(.*)' has file groups with fields:$/ do |title, table|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  table.hashes.each do |hash|
    FactoryGirl.create(:file_group, hash.merge({:collection => collection}))
  end
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

When(/^I view events for the file group named '(.*)'$/) do |name|
  visit events_file_group_path(FileGroup.find_by_name(name))
end

And(/^I should be viewing events for the file group named '(.*)'$/) do |name|
  current_path.should == events_file_group_path(FileGroup.find_by_name(name))
end

And /^The collection titled '(.*)' should not have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:external_file_location => location).should be_empty
end

And /^The collection titled '(.*)' should have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:external_file_location => location).should_not be_empty
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

And(/^the file group named '(.*)' should have a target file group named '(.*)'$/) do |source_name, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  source_file_group.target_file_groups.include?(target_file_group).should be_true
end

And(/^the file group named '(.*)' should not have a target file group named '(.*)'$/) do |source_name, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  source_file_group.target_file_groups.include?(target_file_group).should be_false
end

And(/^the file group named '(.*)' has a target file group named '(.*)'$/) do |source_name, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  source_file_group.target_file_groups << target_file_group
end

And(/^the file group named '(.*)' should have relation note '(.*)' for the target file group '(.*)'$/) do |source_name, note, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  source_file_group.target_relation_note(target_file_group).should == note
end

And(/^the file group named '(.*)' has relation note '(.*)' for the target file group '(.*)'$/) do |source_name, note, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  join = RelatedFileGroupJoin.find_or_create_by(source_file_group_id: source_file_group.id, target_file_group_id: target_file_group.id)
  join.note = note
  join.save!
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