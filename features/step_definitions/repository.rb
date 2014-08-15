Then /^A repository with title '(.*)' should exist$/ do |repository_title|
  Repository.find_by_title(repository_title).should_not be_nil
end

And /^I have repositories with fields:$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create :repository, hash
  end
end

And /^the repository titled '(.*)' is managed by '(.*)'$/ do |title, email|
  person = FactoryGirl.create(:person, :email => email,)
  FactoryGirl.create(:repository, :contact => person, :title => title)
end


And /^the repository titled '(.*)' has collections with fields:$/ do |repository_title, table|
  repository = Repository.find_by(title: repository_title) || FactoryGirl.create(:repository, title: repository_title)
  table.hashes.each do |hash|
    FactoryGirl.create(:collection, hash.merge(:repository => repository))
  end
end

When /^the repository titled '(.*)' has been deleted$/ do |title|
  Repository.find_by_title(title).destroy
end

Then /^I should see the repository collection table$/ do
  page.should have_selector('table#collections')
end

And /^I click on 'Delete' in the collections table$/ do
  within_table('collections') do
    click_on 'Delete'
  end
end

Then /^I should see all repository fields$/ do
  ['Title', 'URL', 'Notes', 'Address 1', 'Address 2', 'City', 'State', 'Zip', 'Phone Number', 'Email'].each do |field|
    step "I should see '#{field}'"
  end
end

When /^I view the repository having a collection titled '(.*)'$/ do |title|
  collection = Collection.find_by_title(title)
  visit repository_path(collection.repository)
end

And /^I have some repositories with files totalling '(\d+)' GB$/ do |size|
  size = size.to_i
  raise(RuntimeError, 'Please use an integral value for this test') unless size.integer?
  repositories = 3.times.collect { FactoryGirl.create(:repository) }
  repositories.each do |r|
    3.times do
      FactoryGirl.create(:collection, :repository => r)
    end
  end
  decompose_size(size).each do |x|
    repository = repositories.sample
    collection = repository.collections.sample
    FactoryGirl.create(:file_group, :collection => collection, :total_file_size => x)
  end
end

And(/^the repository titled '(.*)' has an assessment named '(.*)'$/) do |title, name|
  repository = Repository.find_by_title(title)
  FactoryGirl.create(:assessment, :name => name, :assessable_id => repository.id, :assessable_type => 'Repository')
end

And(/^the repository titled '(.*)' should have (\d+) assessments$/) do |title, count|
  Repository.find_by_title(title).assessments.count.to_s.should == count
end

Then(/^I should be editing repository administration groups$/) do
  expect(page.current_path).to eq(edit_ldap_admins_repositories_path)
end

#break down number into summands of powers of two - just a convenient way to
#get some different sizes from a single number for the above step
def decompose_size(size, current = 1, acc = [])
  return acc if size == 0
  acc << current if size % 2 == 1
  decompose_size(size / 2, current * 2, acc)
end