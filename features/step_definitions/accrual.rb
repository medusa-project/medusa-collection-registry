And(/^the bag '(.*)' is staged in the accrual root named '(.*)' at path '(.*)'$/) do |bag_name, root_name, path|
  StorageManager.instance.accrual_roots.at(root_name).copy_tree_to(path, FixtureFileHelper.storage_root, FixtureFileHelper.complete_bag_key(bag_name))
end

And(/^I should see the accrual form and dialog$/) do
  expect(page).to have_selector('form#add-files-form')
  expect(page).to have_selector('#add-files-dialog')
end

And(/^I should not see the accrual form and dialog$/) do
  expect(page).not_to have_selector('form#add-files-form')
  expect(page).not_to have_selector('#add-files-dialog')
end

Then(/^the cfs directory with path '(.*)' should have an accrual job with (\d+) files? and (\d+) director(?:y|ies)$/) do |path, file_count, directory_count|
  cfs_directory = CfsDirectory.find_by(path: path)
  accrual_job = Workflow::AccrualJob.find_by(cfs_directory_id: cfs_directory.id)
  expect(accrual_job.workflow_accrual_files.count).to eql(file_count.to_i)
  expect(accrual_job.workflow_accrual_directories.count).to eql(directory_count.to_i)
end

Then(/^the cfs directory with path '(.*)' should have an accrual job with (\d+) keys?$/) do |path, key_count|
  cfs_directory = CfsDirectory.find_by(path: path)
  accrual_job = Workflow::AccrualJob.find_by(cfs_directory_id: cfs_directory.id)
  expect(accrual_job.workflow_accrual_keys.count).to eql(key_count.to_i)
end

And(/^the cfs directory with path '(.*)' should have an accrual job with (\d+) minor conflicts? and (\d+) serious conflicts?$/) do |path, minor_conflict_count, serious_conflict_count|
  cfs_directory = CfsDirectory.find_by(path: path)
  accrual_job = Workflow::AccrualJob.find_by(cfs_directory_id: cfs_directory.id)
  expect(accrual_job.workflow_accrual_conflicts.not_serious.count).to eql(minor_conflict_count.to_i)
  expect(accrual_job.workflow_accrual_conflicts.serious.count).to eql(serious_conflict_count.to_i)
end

Then(/^the cfs directory with path '(.*)' should not have an accrual job$/) do |path|
  cfs_directory = CfsDirectory.find_by(path: path)
  accrual_job = Workflow::AccrualJob.find_by(cfs_directory_id: cfs_directory.id)
  expect(accrual_job).to be_nil
end

When /^I select accrual action '([^']*)'$/ do |action|
  steps %Q(
    When I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on '#{action}'
    And I wait 1 second
    When delayed jobs are run)
end

When /^I select accrual action '([^']*)' with comment '([^']*)'$/ do |action, comment|
  steps %Q(
    When I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on '#{action}'
    And I fill in fields:
      | Comment | #{comment} |
    And within '#accrual_comment_form' I click on 'Submit'
    And I wait 0.5 seconds
    When delayed jobs are run
    And I wait 0.5 seconds)
end

Then /^accrual assessment for the cfs directory with path '(.*)' has (\d+) files?, (\d+) director(?:y|ies), (\d+) minor conflicts?, and (\d+) serious conflicts?$/ do |path, file_count, directory_count, minor_conflict_count, serious_conflict_count|
  steps %Q(
    Then the cfs directory with path '#{path}' should have an accrual job with #{file_count} files and #{directory_count} directories
    When delayed jobs are run
    Then the cfs directory with path '#{path}' should have an accrual job with #{file_count} files and #{directory_count} directories
    And the cfs directory with path '#{path}' should have an accrual job with #{minor_conflict_count} minor conflicts and #{serious_conflict_count} serious conflicts)
end

Then /^accrual assessment for the cfs directory with path '(.*)' has a zero file '(.*)'$/ do |cfs_directory_path, zero_file_path|
  cfs_directory = CfsDirectory.find_by(path: cfs_directory_path)
  accrual_job = Workflow::AccrualJob.find_by(cfs_directory_id: cfs_directory.id)
  expect(accrual_job.empty_file_report.each_line.detect {|line| line.chomp == zero_file_path}).to be_truthy
end

When /^I navigate to my accrual data for bag '(.*)' at path '(.*)'$/ do |bag_name, path|
  steps %Q(
  When the bag '#{bag_name}' is staged in the accrual root named 'staging-1' at path '#{path}'
  And I view the bit level file group with title 'Dogs'
  And I click on 'Run'
  And I click consecutively on:
    | Add files | staging-1 | dogs |
  And within '#add-files-form' I click on 'data')
end

Given(/^there is an accrual workflow job awaiting admin approval$/) do
  FactoryBot.create(:workflow_accrual_job, state: 'admin_approval')
end