When(/^I perform file group deletion workflows$/) do
  Workflow::FileGroupDelete.all.each do |workflow|
    workflow.perform
  end
end

And(/^there should be (\d+) file group deletion workflow in state '(.*)'$/) do |count, state|
  expect(Workflow::FileGroupDelete.where(state: state).count).to eq(count.to_i)
end

And(/^there should be (\d+) file group deletion workflow delayed jobs?$/) do |count|
  expect(Workflow::FileGroupDelete.all.collect(&:delayed_jobs).flatten.count).to eq(count.to_i)
end

Given(/^the user '(.*)' has a file group deletion workflow with fields:$/) do |user, table|
  user = User.find_by(email: user) || FactoryBot.create(:user, uid: user, email: user)
  FactoryBot.create(:workflow_file_group_delete, table.hashes.first.merge(requester: user))
end

Then(/^there should be (\d+) file group deletion workflows?$/) do |count|
  expect(Workflow::FileGroupDelete.count).to eq(count.to_i)
end

And(/^there should be file group delete backup tables:$/) do |table|
  table.headers.each do |table_name|
    expect(ActiveRecord::Base.connection.data_source_exists?(table_name)).to be_truthy
  end
end

And(/^there should not be file group delete backup tables:$/) do |table|
  table.headers.each do |table_name|
    expect(ActiveRecord::Base.connection.data_source_exists?(table_name)).to be_falsey
  end
end

And(/^the delete notification file should exist for '(.*)'$/) do |key_prefix|
  key = File.join(key_prefix, 'THIS_DIRECTORY_TO_BE_DELETED')
  expect(StorageManager.instance.main_root.exist?(key)).to be_truthy
end

And(/^the delete notification file should not exist for '(.*)'$/) do |key_prefix|
  key = File.join(key_prefix, 'THIS_DIRECTORY_TO_BE_DELETED')
  expect(StorageManager.instance.main_root.exist?(key)).to be_falsey
end