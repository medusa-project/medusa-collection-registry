Then /^I should be on the new collection page$/ do
  current_path.should == new_collection_path
end

Then /^I should be on the view page for the collection titled '(.*)'$/ do |title|
 current_path.should == collection_path(Collection.find_by_title(title))
end

Then /^I should be on the edit page for the collection titled '(.*)'$/ do |title|
  current_path.should == edit_collection_path(Collection.find_by_title(title))
end

And /^the repository titled '(.*)' should have a collection titled '(.*)'$/ do |repository_title, collection_title|
  Collection.find_by_title(collection_title).repository.should ==
      Repository.find_by_title(repository_title)
end