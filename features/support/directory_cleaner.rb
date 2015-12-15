require 'fileutils'

#before each test make sure that the cfs directories, any staging directories, item_upload_csv directories are empty
Before do
  Dir[File.join(CfsDirectory.export_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end

  Dir[File.join(CfsRoot.instance.path, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end

  StagingStorage.instance.roots.each do |root|
    if File.directory?(root.local_path)
      Dir[File.join(root.local_path, '*')].each do |dir|
        FileUtils.rm_rf(dir)
      end
    end
  end
  AccrualStorage.instance.roots.each do |root|
    if File.directory?(root.local_path)
      Dir[File.join(root.local_path, '*')].each do |dir|
        FileUtils.rm_rf(dir)
      end
    end
  end

  Dir[File.join(Job::ItemBulkImport.csv_file_location_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end

end
