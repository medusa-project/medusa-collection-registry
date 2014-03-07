require 'pathname'
module CfsHelper
  def cfs_directory_select_collection
    Dir.chdir(Cfs.root) do
      Dir[File.join('*', '*')].select do |entry|
        File.directory?(entry)
      end.sort
    end
  rescue
    #TODO - possibly send an email when this happens
    Rails.logger.error 'CFS directory not found'
    []
  end

  def cfs_file_info_path(cfs_file_info)
    cfs_show_path(:path => cfs_file_info.path)
  end

end