And(/^the staging storage has a key '([^']*)' with contents '([^']*)'$/) do |key, contents|
  staging_storage_root.write_string_to(key, contents)
end

And(/^the staging storage should have a key '([^']*)' with contents '([^']*)'$/) do |key, contents|
  expect(main_storage_root.exist?(key)).to be_truthy
  file_content = staging_storage_root.with_input_io(key) do |io|
    io.read
  end
  expect(file_content).to match(contents)
end

And(/^the staging storage has a directory key '([^']*)' containing a file$/) do |key|
  step "the main storage has a key '#{key}/stuff' with contents 'some stuff'"
end

And(/^the staging storage directory key '([^']*)' contains cfs fixture content '([^']*)'$/) do |dir_key, fixture_key|
  staging_storage_root.copy_content_to(File.join(dir_key, File.basename(fixture_key)),
                                    FixtureFileHelper.storage_root, fixture_key)
end

And(/^the staging storage directory key '([^']*)' contains the data of bag '([^']*)'$/) do |dir_key, bag_name|
  staging_storage_root.copy_tree_to(dir_key, FixtureFileHelper.storage_root, FixtureFileHelper.bag_key(bag_name))
end

#The key may be for a single file or an entire tree
When(/^I remove the staging storage tree '([^']*)'$/) do |key|
  staging_storage_root.delete_tree(key)
end

And(/^the staging storage should have content under '(.*)'$/) do |key|
  expect(staging_storage_content_exists_under?(key)).to be_truthy
end

And(/^the staging storage should not have content under '(.*)'$/) do |key|
  expect(staging_storage_content_exists_under?(key)).to be_falsey
end

def staging_storage_root
  StorageManager.instance.project_staging_root
end

def staging_storage_content_exists_under?(key)
  staging_storage_root.subtree_keys(key).present?
rescue MedusaStorage::Error::InvalidDirectory
  false
end
