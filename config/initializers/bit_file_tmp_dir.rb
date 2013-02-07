require 'fileutils'
MedusaRails3::Application.bit_file_tmp_dir = File.join('tmp', 'bit_file_tmp_dir')
FileUtils.mkdir_p(MedusaRails3::Application.bit_file_tmp_dir)
Dir[File.join(MedusaRails3::Application.bit_file_tmp_dir, '*')].each {|f| File.unlink(f)}