require 'fileutils'
class Job::CfsDirectoryExport < Job::Base
  belongs_to :user
  belongs_to :cfs_directory

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
    CfsMailer.export_complete(self).deliver
    if CfsDirectory.export_autoclean
      CfsDirectoryExportCleanup.create_for(self.export_directory)
    end
    self.destroy
  end

  #TODO - make this more useful, but that needs to wait until we know better
  #how we're going to do the pickup
  def pickup_path()
    self.uuid
  end

  def export_directory
    File.join(CfsDirectory.export_root, self.uuid)
  end

end