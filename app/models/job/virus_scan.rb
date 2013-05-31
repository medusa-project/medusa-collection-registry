class Job::VirusScan < ActiveRecord::Base
  attr_accessible :file_group_id

  belongs_to :file_group

  def perform
    VirusScan.check_file_group(FileGroup.find(self.file_group))
  end

  def success(job)
    self.destroy
  end

end
