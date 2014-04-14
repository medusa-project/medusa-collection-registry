require 'singleton'
require 'set'

class CfsRoot
  include Singleton

  attr_accessor :path, :config

  def initialize
    self.config = MedusaRails3::Application.medusa_config['cfs']
    self.path = config['root']
  end

  #Return a list of roots from the file system that are not currently being
  #used by a file group. Create CfsDirectory objects as needed. Clear any
  #CfsDirectory objects that are potential roots but are not on the file system.
  #TODO - this is somewhat complex, can it be refactored? There are easier ways to do
  #it, but they would involve more database access.
  def available_roots
    ActiveRecord::Base.transaction do
      physical_root_set = Dir.chdir(self.path) do
        Dir[File.join('*', '*')].select do |entry|
          File.directory?(entry)
        end
      end.to_set
      all_database_root_hash = Hash.new.tap do |h|
        CfsDirectory.includes(:file_group).where(parent_cfs_directory_id: nil).each do |cfs_directory|
          h[cfs_directory.path] = cfs_directory
        end
      end
      used_database_root_set = all_database_root_hash.select do |path, cfs_directory|
        cfs_directory.file_group.present?
      end.keys.to_set
      available_database_root_set = all_database_root_hash.select do |path, cfs_directory|
        cfs_directory.file_group.blank?
      end.keys.to_set
      available_physical_root_set = physical_root_set - used_database_root_set
      (available_database_root_set - available_physical_root_set).each do |path|
        #remove from database if nothing is attached to it
        cfs_directory = all_database_root_hash[path]
        if cfs_directory.cfs_files.blank? and cfs_directory.subdirectories.blank?
          cfs_directory.destroy!
          all_database_root_hash.delete(path)
        end
      end
      (available_physical_root_set - available_database_root_set).each do |path|
        new_root = CfsDirectory.create(:path => path)
        available_database_root_set.add(path)
        all_database_root_hash[path] = new_root
      end
      x = available_database_root_set.collect { |path| all_database_root_hash[path] }.sort_by(&:path)
      return x
    end
  end

end