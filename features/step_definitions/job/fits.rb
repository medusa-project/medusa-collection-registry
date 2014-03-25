And(/^I am running a fits job for the file group named '(.*)' with (\d+) files$/) do |name, count|
  file_group = FileGroup.find_by_name(name)
  FactoryGirl.create(:fits_directory_job, :cfs_directory => file_group.cfs_directory,
                     :file_group => file_group, :file_count => count)
end

And(/^I am running an initial assessment job for the file group named '(.*)' with (\d+) files$/) do |name, count|
  file_group = FileGroup.find_by_name(name)
  FactoryGirl.create(:cfs_initial_directory_assessment_job, :cfs_directory => file_group.cfs_directory,
                     :file_group => file_group, :file_count => count)
end

Given(/^there are (\d+) failed delayed jobs$/) do |count|
  count.to_i.times do
    Delayed::Job.create(:failed_at => Time.now)
  end
end