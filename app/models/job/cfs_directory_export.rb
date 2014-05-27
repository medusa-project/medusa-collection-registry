require 'fileutils'
class Job::CfsDirectoryExport < Job::Base
  belongs_to :user
  belongs_to :cfs_directory

  def self.create_for(cfs_directory, user, recursive)
    Delayed::Job.enqueue(self.create(cfs_directory: cfs_directory, user: user, uuid: UUID.generate, recursive: recursive))
  end

  def perform
    export_directory = File.join(CfsDirectory.export_root, self.uuid)
    FileUtils.rm_rf(export_directory)
    FileUtils.mkdir_p(export_directory)
    self.cfs_directory.cfs_files.each do |file|
      FileUtils.copy(file.absolute_path, File.join(export_directory, file.name))
    end
    if self.recursive
      self.cfs_directory.subdirectories.each do |subdirectory|
        FileUtils.cp_r(subdirectory.absolute_path, File.join(export_directory))
      end
    end
  end

  def success(job)
    #email the success, schedule cleanup if appropriate, and then destroy self
  end

end