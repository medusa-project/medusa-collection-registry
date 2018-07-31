require 'fileutils'

#before each test make sure that the cfs directories, any staging directories, item_upload_csv directories are empty
Before do

  [CfsDirectory.export_root, Job::ItemBulkImport.csv_file_location_root,
   FitsResult.storage_root, Settings.medusa.cfs.fg_delete_holding].each do |path|
    Dir[File.join(path, '*')].each do |dir|
      FileUtils.rm_rf(dir) if File.exist?(dir)
    end
  end

  Application.storage_manager.main_root.delete_all_content
  Application.storage_manager.project_staging_root.delete_all_content
  Application.storage_manager.accrual_roots.all_roots.each {|root| root.delete_all_content}
  Application.storage_manager.amqp_roots.all_roots.each {|root| root.delete_all_content}

end
