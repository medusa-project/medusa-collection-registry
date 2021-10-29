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
    storage_key = unique_key
    storage_path = File.join(Application.storage_manager.reports_root.path, storage_key)
    File.open(storage_path, "w" ){}
    report = Report::CfsDirectoryManifest.new(cfs_directory)
    report.generate_tsv(storage_path)
    ReportMailer.cfs_directory_manifest(self, storage_path).deliver_now
    Application.storage_manager.reports_root.delete_content(storage_key)
  end

  private

  def unique_key
    proposed_key = nil
    loop do
      timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
      proposed_key = "manifest_id#{self.cfs_directory.id.to_s}_ts#{timestamp}"
      break unless Application.storage_manager.reports_root.exist?(proposed_key)
      sleep(1)
    end
    proposed_key
  end

end
