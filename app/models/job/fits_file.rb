class Job::FitsFile < ActiveRecord::Base
  belongs_to :fits_directory_tree, touch: true

  def perform
    Cfs.ensure_fits_for(self.path)
  end

  def success(job)
    self.destroy
    #if this was the last file for the parent job then that job can be removed. If not it should be left for reporting
    #purposes
    if parent = self.fits_directory_tree
      if parent.fits_files.count == 0
        parent.destroy
      end
    end
  end

end
