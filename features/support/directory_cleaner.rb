require 'fileutils'
#before each test make sure that the cfs directories, any staging directories, item_upload_csv directories are empty
Before do

  [Job::ItemBulkImport.csv_file_location_root].each do |path|
    Dir[File.join(path, '*')].each do |dir|
      FileUtils.rm_rf(dir) if File.exist?(dir)
    end
  end

  StorageManager.instance.main_root.delete_all_content
  StorageManager.instance.project_staging_root.delete_all_content
  StorageManager.instance.accrual_roots.all_roots.each {|root| root.delete_all_content}
  StorageManager.instance.amqp_roots.all_roots.each {|root| root.delete_all_content}
  StorageManager.instance.fits_root.delete_all_content

end
