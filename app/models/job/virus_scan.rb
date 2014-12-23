class Job::VirusScan < Job::Base
  belongs_to :file_group, touch: true

  def perform
    VirusScan.check_file_group(self.file_group)
  end

end
