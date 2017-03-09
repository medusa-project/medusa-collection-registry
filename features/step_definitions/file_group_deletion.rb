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

When(/^I admin decide on the file group delete workflow$/) do
  workflow = Workflow::FileGroupDelete.first
  visit(admin_decide_workflow_file_group_delete_path(workflow))
end