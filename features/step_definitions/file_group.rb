Then /^I should see the file group id for the file group with location '(.*)' in the file group collection table$/ do |location|
  id = FileGroup.find_by(external_file_location: location).id
  within_table('file_groups') do
    step "I should see '#{id}'"
  end
end

And /^I should not see '(.*)' in the related file groups section$/ do |string|
  within('#related-file-groups') do
    step "I should not see '#{string}'"
  end
end

And /^The file group with location '(.*)' for the collection titled '(.*)' should have producer titled '(.*)'$/ do |location, collection_title, producer_title|
  find_file_group(collection_title, location).producer.title.should == producer_title
end

Given /^The file group with location '(.*)' for the collection titled '(.*)' has producer titled '(.*)'$/ do |location, collection_title, producer_title|
  file_group = find_file_group(collection_title, location)
  file_group.producer = Producer.find_by(title: producer_title)
  file_group.save
end

And(/^the file group titled '(.*)' has a target file group titled '(.*)'$/) do |source_title, target_title|
  source_file_group = FileGroup.find_by(title: source_title)
  target_file_group = FileGroup.find_by(title: target_title)
  source_file_group.target_file_groups << target_file_group
end

And(/^the file group titled '(.*)' should have relation note '(.*)' for the target file group '(.*)'$/) do |source_title, note, target_title|
  source_file_group = FileGroup.find_by(title: source_title)
  target_file_group = FileGroup.find_by(title: target_title)
  source_file_group.target_relation_note(target_file_group).should == note
end

And(/^the file group titled '(.*)' has relation note '(.*)' for the target file group '(.*)'$/) do |source_title, note, target_title|
  source_file_group = FileGroup.find_by(title: source_title)
  target_file_group = FileGroup.find_by(title: target_title)
  join = RelatedFileGroupJoin.find_or_create_by(source_file_group_id: source_file_group.id, target_file_group_id: target_file_group.id)
  join.note = note
  join.save!
end

And(/^the cfs root for the file group titled '(.*)' should be nil$/) do |title|
  FileGroup.find_by(title: title).cfs_root.should be_nil
end

Then(/^a visitor is unauthorized to start a file group for the collection titled '(.*)'$/) do |title|
  rack_login('a visitor')
  get new_file_group_path(collection_id: Collection.find_by(title: title).id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

Then(/^a visitor is unauthorized to create a file group for the collection titled '(.*)'$/) do |title|
  rack_login('a visitor')
  post file_groups_path(file_group: {collection_id: Collection.find_by(title: title).id,
                                        storage_level: 'bit-level store'})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{unauthorized_path}$/)
end

private

def find_file_group(collection_title, location)
  collection = Collection.find_by(title: collection_title)
  collection.file_groups.where(external_file_location: location).first
end