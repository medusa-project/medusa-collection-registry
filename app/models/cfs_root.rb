require 'singleton'
require 'set'
require 'timeout'
require 'pathname'

class CfsRoot
  include Singleton

  attr_accessor :path, :tmp_path

  def initialize
    self.path = Settings.medusa.cfs.root
    self.tmp_path = Settings.medusa.cfs.tmp.if_blank('/tmp')
  end

  #Return a list of roots from the file system that are not currently being
  #used by a file group. Create CfsDirectory objects as needed. Clear any
  #CfsDirectory objects that are potential roots but are not on the file system.
  #TODO - this is somewhat complex, can it be refactored? There are easier ways to do
  #it, but they would involve more database access.
  def available_roots
    ActiveRecord::Base.transaction do
      physical_root_set = available_physical_root_set
      all_database_root_hash = Hash.new.tap do |h|
        CfsDirectory.roots.includes(:parent).each do |cfs_directory|
          h[cfs_directory.path] = cfs_directory
        end
      end
      used_database_root_set = all_database_root_hash.select do |path, cfs_directory|
        cfs_directory.parent.present?
      end.keys.to_set
      available_database_root_set = all_database_root_hash.select do |path, cfs_directory|
        cfs_directory.parent.blank?
      end.keys.to_set
      available_physical_root_set = physical_root_set - used_database_root_set
      (available_database_root_set - available_physical_root_set).each do |path|
        #remove from database if nothing is attached to it
        cfs_directory = all_database_root_hash[path]
        if cfs_directory.cfs_files.blank? and cfs_directory.subdirectories.blank?
          cfs_directory.destroy!
          all_database_root_hash.delete(path)
          available_database_root_set.delete(path)
        end
      end
      (available_physical_root_set - available_database_root_set).each do |path|
        new_root = CfsDirectory.create(path: path)
        available_database_root_set.add(path)
        all_database_root_hash[path] = new_root
      end
      x = available_database_root_set.collect { |path| all_database_root_hash[path] }.sort_by(&:path)
      return x
    end
  end

  def available_physical_root_set
    Timeout::timeout(20) do
      roots = self.non_cached_physical_root_set
      roots.tap do |root_set|
        Rails.cache.write(self.physical_root_set_cache_key, root_set)
      end
    end
  rescue Timeout::Error
    Rails.cache.read(self.physical_root_set_cache_key) || [].to_set
  end

  def non_cached_physical_root_set
    root = Pathname.new(self.path)
    children = root.children.select { |entry| entry.directory? }
    grandchildren = children.collect { |child| child.children.select { |entry| entry.directory? } }.flatten
    grandchildren.collect { |grandchild| grandchild.relative_path_from(root).to_s }.to_set
  end

  def physical_root_set_cache_key
    :cfs_physical_root_set
  end

end