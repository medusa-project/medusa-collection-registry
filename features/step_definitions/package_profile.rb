And(/^I have package profiles with fields:$/) do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:package_profile, hash)
  end
end

Then(/^I should be on the collection index page for collections with package profile 'book'$/) do
  current_path.should == for_package_profile_collections_path
end

And(/^the file group named '(.*)' has package profile named '(.*)'$/) do |file_group_name, package_profile_name|
  file_group = FileGroup.find_by_name(file_group_name) || FactoryGirl.create(:file_group, :name => file_group_name)
  package_profile = PackageProfile.find_by_name(package_profile_name) || FactoryGirl.create(:package_profile, :name => package_profile_name)
  file_group.package_profile = package_profile
  file_group.save!
end

Then(/^the file group named '(.*)' should have package profile named '(.*)'$/) do |file_group_name, package_profile_name|
  file_group = FileGroup.find_by_name(file_group_name)
  package_profile = PackageProfile.find_by_name(package_profile_name)
  file_group.package_profile.should == package_profile
end

And(/^the collection titled '(.*)' has a file group with package profile named '(.*)'$/) do |title, name|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  file_group = FactoryGirl.create(:file_group, :collection_id => collection.id)
  package_profile = PackageProfile.find_by_name(name) || FactoryGirl.create(:package_profile, :name => name)
  file_group.package_profile = package_profile
  file_group.save!
end