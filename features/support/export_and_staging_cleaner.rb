require 'fileutils'

#before each test make sure that the export directory and any staging directories are empty
Before do
  Dir[File.join(CfsDirectory.export_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end

  StagingStorage.instance.roots.each do |root|
    if File.directory?(root.local_path)
      Dir[File.join(root.local_path, '*')].each do |dir|
        FileUtils.rm_rf(dir)
      end
    end
  end
end
