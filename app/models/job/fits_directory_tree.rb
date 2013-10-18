class Job::FitsDirectoryTree < ActiveRecord::Base
  #attr_accessible :path
  has_many :fits_files

  def perform
    Cfs.ensure_fits_for_tree(self.path, self)
  end

  #if this corresponds to a file group then return it, else nil
  def file_group
    FileGroup.find_by_cfs_path(self.path)
  end

end
