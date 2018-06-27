require 'fileutils'

#before each test make sure that the cfs directories, any staging directories, item_upload_csv directories are empty
Before do

  [CfsDirectory.export_root, CfsRoot.instance.path, Job::ItemBulkImport.csv_file_location_root,
   FitsResult.storage_root, Settings.medusa.cfs.fg_delete_holding].each do |path|
    Dir[File.join(path, '*')].each do |dir|
      FileUtils.rm_rf(dir) if File.exist?(dir)
    end
  end

  [StagingStorage, AccrualStorage].each do |storage|
    storage.instance.roots.each do |root|
      if File.directory?(root.local_path)
        Dir[File.join(root.local_path, '*')].each do |dir|
          FileUtils.rm_rf(dir)
        end
      end
    end
  end

  Application.main_storage_root.delete_all_content

end
