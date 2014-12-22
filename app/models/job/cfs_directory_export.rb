require 'fileutils'
class Job::CfsDirectoryExport < Job::Base
  belongs_to :user, touch: true
  belongs_to :cfs_directory, touch: true

  def self.create_for(cfs_directory, user, recursive)
    Delayed::Job.enqueue(self.create(cfs_directory: cfs_directory, user: user, uuid: UUID.generate, recursive: recursive))
  end

  def perform
    FileUtils.rm_rf(self.export_directory)
    FileUtils.mkdir_p(self.export_directory)
    self.cfs_directory.cfs_files.each do |file|
      FileUtils.copy(file.absolute_path, File.join(self.export_directory, file.name))
    end
    if self.recursive
      self.cfs_directory.subdirectories.each do |subdirectory|
        FileUtils.cp_r(subdirectory.absolute_path, File.join(self.export_directory))
      end
    end
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
  def pickup_path()
    "\\\\storage.library.illinois.edu\\MedusaExports\\#{self.group_directory}\\#{self.uuid}"
  end

  def export_directory
    File.join(CfsDirectory.export_root, self.group_directory, self.uuid)
  end

  def group_directory
    (self.cfs_directory.repository.ldap_admin_group || ApplicationController.admin_ad_group).gsub(' ', '_')
  end

end