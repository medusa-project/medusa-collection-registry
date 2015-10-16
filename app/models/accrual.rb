class Accrual
  include Draper::Decoratable

  attr_accessor :cfs_directory, :staging_path

  def initialize(args = {})
    self.cfs_directory = args[:cfs_directory]
    self.staging_path = args[:staging_path] || '/'
  end

  def at_root?
    self.staging_path == '/'
  end

  def cfs_directory_id
    self.cfs_directory.id
  end

  def path_up
    return '/' if self.at_root?
    return staging_path.sub(/[^\/]*\/$/, '')
  end

  def path_down(directory)
    self.staging_path + directory + '/'
  end

  def staging_root
    AccrualStorage.instance.root_named(staging_root_name)
  end

  def staging_root_name
    staging_path.split('/').drop(1).first
  end

  def path_from_staging_root
    staging_path.split('/').drop(2).join('/')
  end

  def directories
    return Array.new if at_root?
    staging_root.directories_at(path_from_staging_root).collect { |pathname| pathname.basename.to_s }.sort
  end

  def files
    return Array.new if at_root?
    staging_root.files_at(path_from_staging_root).collect { |pathname| pathname.basename.to_s }.sort
  end

end