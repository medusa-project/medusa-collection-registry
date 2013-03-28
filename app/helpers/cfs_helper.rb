require 'pathname'
module CfsHelper
  def cfs_directory_select_collection
    Dir.chdir(MedusaRails3::Application.cfs_root) do
      Dir[File.join('*', '*')].select do |entry|
        File.directory?(entry)
      end.sort
    end
  end
end