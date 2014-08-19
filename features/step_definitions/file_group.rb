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
  source_file_group.target_file_groups.include?(target_file_group).should be_truthy
end

And(/^the file group named '(.*)' should not have a target file group named '(.*)'$/) do |source_name, target_name|
  source_file_group = FileGroup.find_by_name(source_name)
  target_file_group = FileGroup.find_by_name(target_name)
  source_file_group.target_file_groups.include?(target_file_group).should be_falsy
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

Then(/^a visitor is unauthorized to start a file group for the collection titled '(.*)'$/) do |title|
  rack_login('a visitor')
  get new_file_group_path(:collection_id => Collection.find_by(:title => title).id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

Then(/^a visitor is unauthorized to create a file group for the collection titled '(.*)'$/) do |title|
  rack_login('a visitor')
  post file_groups_path(:file_group => {:collection_id => Collection.find_by(:title => title).id,
                                        :storage_level => 'bit-level store'})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

private

def find_file_group(collection_title, location)
  collection = Collection.find_by_title(collection_title)
  collection.file_groups.where(:external_file_location => location).first
end