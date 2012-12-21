And /^the root directory for the collection titled '(.*)' has subdirectories named:$/ do |title, table|
  root = collection_root(title)
  create_subdirs(root, table)
end

And /^the root directory for the collection titled '(.*)' has files with fields:$/ do |title, table|
  root = collection_root(title)
  create_files(root, table)
end

And /^the directory named '(.*)' has files with fields:$/ do |name, table|
  create_files(Directory.find_by_name(name), table)
end

And /^the directory named '(.*)' has subdirectories named:$/ do |name, table|
  create_subdirs(Directory.find_by_name(name), table)
end

Then /^I should be on the view page for the root directory of the collection titled '(.*)'$/ do |title|
  root = collection_root(title)
  current_path.should == directory_path(root)
end

When /^I view the directory named '(.*)'$/ do |name|
  visit directory_path(Directory.find_by_name(name))
end

Then /^I should be on the view page for the directory named '(.*)'$/ do |name|
  current_path.should == directory_path(Directory.find_by_name(name))
end

Then /^I should see a subdirectory table$/ do
  page.should have_selector('#subdirectories')
end

Then /^I should see a file table$/ do
  page.should have_selector('#files')
end

Then /^I should see a cumulative file size table$/ do
  page.should have_selector('#cumulative_file_sizes')
end


def create_subdirs(directory, table)
  table.headers.each do |name|
    directory.children.create(:name => name, :collection_id => directory.collection_id)
  end
end

def create_files(directory, table)
  table.hashes.each do |hash|
    directory.bit_files.create(hash)
  end
end

def collection_root(title)
  collection = Collection.find_by_title(title)
  collection.root_directory
end