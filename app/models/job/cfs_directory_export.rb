require 'fileutils'
class Job::CfsDirectoryExport < Job::Base
  belongs_to :user
  belongs_to :cfs_directory

  def self.create_for(cfs_directory, user, recursive)
    Delayed::Job.enqueue(self.create!(cfs_directory: cfs_directory, user: user, uuid: UUID.generate, recursive: recursive))
  end

  def perform
    FileUtils.mkdir_p(self.export_directory)
    opts = %w(-a --exclude-from) << exclude_file_path
    opts += %w(--exclude */) unless self.recursive
    out, err, status = Open3.capture3('rsync', *opts,
                                      cfs_directory.absolute_path + '/', self.export_directory)
    unless status.success?
      message = <<MESSAGE
Error doing rsync for export job #{self.id}.
STDOUT: #{out}
STDERR: #{err}
Rescheduling.
MESSAGE
      Rails.logger.error message
      raise RuntimeError, message
    end
  end

  def exclude_file_path
    File.join(Rails.root, 'config', 'export_rsync_exclude.txt')
  end

  def success(job)
    CfsMailer.export_complete(self).deliver_now
    if CfsDirectory.export_autoclean
      Job::CfsDirectoryExportCleanup.create_for(self.export_directory)
    end
    super
  end

  #TODO - make this more useful, but that needs to wait until we know better
  #how we're going to do the pickup
  def pickup_path
    "\\\\storage.library.illinois.edu\\MedusaExports\\#{self.group_directory}\\#{self.uuid}"
  end

  def export_directory
    File.join(CfsDirectory.export_root, self.group_directory, self.uuid)
  end

  def group_directory
    (self.cfs_directory.repository.ldap_admin_group || ApplicationController.admin_ad_group).gsub(' ', '_')
  end

end