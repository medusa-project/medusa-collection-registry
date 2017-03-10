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

And(/^there should be (\d+) project item ingest workflow delayed jobs?$/) do |count|
  expect(Workflow::ProjectItemIngest.all.collect(&:delayed_jobs).flatten.count).to eq(count.to_i)
end

Then(/^the project item ingest workflow for the project with title '(.*)' should have items with ingest identifier:$/) do |title, table|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  table.headers.each do |ingest_id|
    item = workflow.items.find_by_ingest_identifier(ingest_id)
    expect(item).to be_truthy
  end
end

Then(/^the project item ingest workflow for the project with title '(.*)' should not have items with ingest identifier:$/) do |title, table|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  table.headers.each do |ingest_id|
    item = workflow.items.find_by_ingest_identifier(ingest_id)
    expect(item).to be_falsey
  end
end

And(/^the project item ingest workflow for the project with title '(.*)' should have user '(.*)'$/) do |title, uid|
  workflow = Project.find_by(title: title).workflow_project_item_ingests.first
  expect(workflow.user.uid).to eq(uid)
end

And(/^there exists staged content for the items with ingest identifiers:$/) do |table|
  table.headers.each do |ingest_id|
    item = Item.find_by(unique_identifier: ingest_id) || Item.find_by(bib_id: ingest_id)
    FileUtils.mkdir_p(item.staging_directory)
    File.open(File.join(item.staging_directory, 'content.txt'), 'w') do |f|
      f.puts item.ingest_identifier
      f.puts 'content'
    end
  end
end

And(/^there is a project item ingest workflow for the project with title '(.*)' in state '(.*)' for items with ingest identifier:$/) do |title, state, table|
  workflow = FactoryGirl.create(:workflow_project_item_ingest, state: state, project: Project.find_by(title: title))
  table.headers.each do |ingest_id|
    item = Item.find_by_ingest_identifier(ingest_id)
    workflow.items << item if item
  end
end