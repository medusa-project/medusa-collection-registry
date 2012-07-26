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

Then /^I should see the assessment collection table$/ do
  page.should have_selector('table#assessments')
end

And /^I click on 'Delete' in the assessments table$/ do
  within_table('assessments') do
    click_on 'Delete'
  end
end

And /^the collection titled 'Dogs' should have (\d+) assessments$/ do |count|
  Collection.find_by_title('Dogs').assessments.count.should == count.to_i
end

Then /^I should see the file group collection table$/ do
  page.should have_selector('table#file_groups')
end

And /^I click on '(.*)' in the file groups table$/ do |button|
  within_table('file_groups') do
    click_on(button)
  end
end
