Then /^I should be on the new collection page$/ do
  current_path.should == new_collection_path
end

Then /^I should be on the view page for the collection titled '(.*)'$/ do |title|
 current_path.should == collection_path(Collection.find_by_title(title))
end