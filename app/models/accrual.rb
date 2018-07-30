class Accrual
  include Draper::Decoratable

  attr_accessor :cfs_directory, :staging_path
  delegate :id, to: :cfs_directory, prefix: true

  def initialize(args = {})
    self.cfs_directory = args[:cfs_directory]
    self.staging_path = args[:staging_path] || '/'
  end

  def at_root?
    self.staging_path == '/'
  end

  def path_up
    return '/' if self.at_root?
    return staging_path.sub(/[^\/]*\/$/, '')
  end

  def path_down(directory)
    self.staging_path + directory + '/'
  end

  def staging_root
    Application.storage_manager.accrual_roots.at(staging_root_name)
  end

  def staging_root_name
    staging_path.split('/').drop(1).first
  end

  def path_from_staging_root
    staging_path.split('/').drop(2).join('/')
  end

  def directories
    return Array.new if at_root?
    staging_root.subdirectory_keys(path_from_staging_root).collect {|d| File.basename(d)}.sort
  end

  def files
    return Array.new if at_root?
    staging_root.file_keys(path_from_staging_root).collect {|f| File.basename(f)}.sort
  end

  def self.available_root_names
    Application.storage_manager.accrual_roots.all_root_names.sort
  end

end