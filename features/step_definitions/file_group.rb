And /^the collection titled '(.*)' has file groups with fields:$/ do |title, table|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  table.hashes.each do |hash|
    FactoryGirl.create(:file_group, hash.merge({:collection => collection}))
  end
end

And /^the collection titled '(.*)' should have (\d+) file group$/ do |title, count|
  Collection.find_by_title(title).file_groups.count.should == count.to_i
end

Then /^I should be on the view page for the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  current_path.should == file_group_path(find_file_group(title, location))
end

Then /^I should be on the edit page for the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  current_path.should == edit_file_group_path(find_file_group(title, location))
end


When /^I view the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  visit file_group_path(find_file_group(title, location))
end

When /^I edit the file group with location '(.*)' for the collection titled '(.*)'$/ do |location, title|
  visit edit_file_group_path(find_file_group(title, location))
end

Given /^I am editing a file group$/ do
  visit edit_file_group_path(FactoryGirl.create(:file_group))
end

And /^The collection titled '(.*)' should not have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:file_location => location).should be_empty
end

And /^The collection titled '(.*)' should have a file group with location '(.*)'$/ do |title, location|
  Collection.find_by_title(title).file_groups.where(:file_location => location).should_not be_empty
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

private

def find_file_group(collection_title, location)
  collection = Collection.find_by_title(collection_title)
  collection.file_groups.where(:file_location => location).first
end