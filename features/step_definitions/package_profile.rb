And(/^I have package profiles with fields:$/) do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:package_profile, hash)
  end
end

When(/^I view the package profile named '(.*)'$/) do |name|
  visit package_profile_path(PackageProfile.find_by_name(name))
end

Then(/^I should be on the view page for the package profile named '(.*)'$/) do |name|
  current_path.should == package_profile_path(PackageProfile.find_by_name(name))
end

When(/^I go to the package profile index page$/) do
  visit package_profiles_path
end

Then(/^I should be on the package profile index page$/) do
  current_path.should == package_profiles_path
end

When(/^I edit the package profile named '(.*)'$/) do |name|
  visit edit_package_profile_path(PackageProfile.find_by_name(name))
end

Then(/^I should be on the edit page for the package profile named '(.*)'$/) do |name|
  current_path.should == edit_package_profile_path(PackageProfile.find_by_name(name))
end

When(/^the collection titled '(.*)' has package profile named '(.*)'$/) do |title, name|
  collection = Collection.find_by_title(title) || FactoryGirl.create(:collection, :title => title)
  package_profile = PackageProfile.find_by_name(name) || FactoryGirl.create(:package_profile, :name => name)
  collection.package_profile = package_profile
  collection.save!
end

Then(/^the collection titled '(.*)' should have package profile named '(.*)'$/) do |title, name|
  collection = Collection.find_by_title(title)
  package_profile = PackageProfile.find_by_name(name)
  collection.package_profile.should == package_profile
end


Then(/^I should be on the collection index page for collections with package profile 'book'$/) do
  current_path.should == for_package_profile_collections_path
end