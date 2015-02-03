require 'fileutils'
MedusaCollectionRegistry::Application.bit_file_tmp_dir = File.join('tmp', 'bit_file_tmp_dir')
FileUtils.mkdir_p(MedusaCollectionRegistry::Application.bit_file_tmp_dir)
Dir[File.join(MedusaCollectionRegistry::Application.bit_file_tmp_dir, '*')].each {|f| File.unlink(f)}