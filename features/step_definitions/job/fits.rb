And(/^I am running a fits job for the file group named '(.*)' with (\d+) files$/) do |name, count|
  file_group = FileGroup.find_by_name(name)
  fits_job = FactoryGirl.create(:fits_directory_tree_job, :path => file_group.cfs_root)
  count.to_i.times do
    FactoryGirl.create(:fits_file_job, :fits_directory_tree => fits_job)
  end
end