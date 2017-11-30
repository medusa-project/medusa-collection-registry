Then(/^I should be on the collection index page for collections with package profile '([^']*)'$/) do |name|
  current_path.should == collections_package_profile_path(PackageProfile.find_by(name: name))
end

And(/^the file group titled '([^']*)' has package profile named '([^']*)'$/) do |title, package_profile_name|
  file_group = FileGroup.find_by(title: title) || FactoryBot.create(:file_group, title: title)
  package_profile = PackageProfile.find_by(name: package_profile_name) || FactoryBot.create(:package_profile, name: package_profile_name)
  file_group.package_profile = package_profile
  file_group.save!
end

Then(/^the file group titled '([^']*)' should have package profile named '([^']*)'$/) do |title, package_profile_name|
  file_group = FileGroup.find_by(title: title)
  package_profile = PackageProfile.find_by(name: package_profile_name)
  file_group.package_profile.should == package_profile
end

And(/^the collection titled '([^']*)' has a file group with package profile named '([^']*)'$/) do |title, name|
  collection = Collection.find_by(title: title) || FactoryBot.create(:collection, title: title)
  file_group = FactoryBot.create(:file_group, collection_id: collection.id)
  package_profile = PackageProfile.find_by(name: name) || FactoryBot.create(:package_profile, name: name)
  file_group.package_profile = package_profile
  file_group.save!
end