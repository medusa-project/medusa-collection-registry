Given(/^there is a project item ingest workflow in state '(.*)'$/) do |state|
  FactoryGirl.create(:workflow_project_item_ingest, state: state)
end

And(/^I perform project item ingest workflows$/) do
  Workflow::ProjectItemIngest.all.each do |workflow|
    workflow.perform
  end
end

Then(/^there should be (\d+) project item ingest workflows?$/) do |count|
  expect(Workflow::ProjectItemIngest.count).to eq(count.to_i)
end

Given(/^the user '(.*)' has a project item ingest workflow in state '(.*)'$/) do |user, state|
  user = FactoryGirl.create(:user, uid: user, email: user)
  FactoryGirl.create(:workflow_project_item_ingest, state: state, user: user)
end

And(/^there should be (\d+) project item ingest workflows? in state '(.*)'$/) do |count, state|
  expect(Workflow::ProjectItemIngest.where(state: state).count).to eq(count.to_i)
end

And(/^there should be (\d+) project item ingest workflows? delayed job$/) do |count|
  expect(Workflow::ProjectItemIngest.all.collect(&:delayed_jobs).flatten.count).to eq(count.to_i)
end