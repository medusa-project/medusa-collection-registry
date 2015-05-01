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

end