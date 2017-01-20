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

Then(/^the project item ingest workflow for the project with title '(.*)' should have items with unique_identifier:$/) do |title, table|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  table.headers.each do |item_unique_id|
    expect(workflow.items.find_by(unique_identifier: item_unique_id)).to be_truthy
  end
end

Then(/^the project item ingest workflow for the project with title '(.*)' should not have items with unique_identifier:$/) do |title, table|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  table.headers.each do |item_unique_id|
    expect(workflow.items.find_by(unique_identifier: item_unique_id)).to be_falsey
  end
end

And(/^the project item ingest workflow for the project with title '(.*)' should have user '(.*)'$/) do |title, uid|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  expect(workflow.user.uid).to eq(uid)
end