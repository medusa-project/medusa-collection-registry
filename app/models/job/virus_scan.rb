class Job::VirusScan < ActiveRecord::Base
  belongs_to :file_group, touch: true

  def perform
    VirusScan.check_file_group(FileGroup.find(self.file_group))
  end

end
