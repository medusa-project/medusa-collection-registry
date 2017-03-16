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
  user = User.find_by(email: user) || FactoryGirl.create(:user, uid: user, email: user)
  FactoryGirl.create(:workflow_file_group_delete, table.hashes.first.merge(requester: user))
end

Then(/^there should be (\d+) file group deletion workflows?$/) do |count|
  expect(Workflow::FileGroupDelete.count).to eq(count.to_i)
end

And(/^there should be a physical file group delete holding directory '(.*)' with (\d+) files$/) do |path, count|
  holding_directory = File.join(Settings.medusa.cfs.fg_delete_holding, path)
  expect(Dir.exist?(holding_directory)).to be_truthy
  tree_file_count = Dir[File.join(holding_directory, '**', '*')].count { |file| File.file?(file) }
  expect(tree_file_count).to eq(count.to_i)
end

And(/^there should not be a physical file group delete holding directory '(.*)'$/) do |path|
  holding_directory = File.join(Settings.medusa.cfs.fg_delete_holding, path)
  expect(Dir.exist?(holding_directory)).to be_falsey
end

And(/^there should be file group delete backup tables:$/) do |table|
  table.headers.each do |table_name|
    expect(ActiveRecord::Base.connection.table_exists?(table_name)).to be_truthy
  end
end

Then(/^there should not be file group delete backup tables:$/) do |table|
  table.headers.each do |table_name|
    expect(ActiveRecord::Base.connection.table_exists?(table_name)).to be_falsey
  end
end

