class Job::Report::CfsDirectoryManifest < Job::Base
  belongs_to :user
  belongs_to :cfs_directory

  def self.create_for(user, cfs_directory)
    job = self.create!(user: user, cfs_directory: cfs_directory)
    job.enqueue_job
  end

  def queue
    Settings.delayed_job.short_queue
  end

  def perform
    report = Report::CfsDirectoryManifest.new(cfs_directory)
    io = StringIO.new
    report.generate_tsv(io)
    ReportMailer.cfs_directory_manifest(self, io).deliver_now
  end

end
