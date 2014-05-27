require 'fileutils'

#before each test make sure that the export directory is empty
Before do
  Dir[File.join(CfsDirectory.export_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
end
