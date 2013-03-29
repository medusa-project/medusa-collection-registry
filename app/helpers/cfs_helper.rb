require 'pathname'
module CfsHelper
  def cfs_directory_select_collection
    Dir.chdir(Cfs.root) do
      Dir[File.join('*', '*')].select do |entry|
        File.directory?(entry)
      end.sort
    end
  end
end