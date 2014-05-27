require 'fileutils'

class Job::CfsDirectoryExportCleanup < Job::Base

  def self.create_for(directory, delay_time = nil)
    delay_time ||= 7.days
    Delayed::Job.enqueue(self.create(directory: directory), run_at: Time.now + delay_time)
  end

  def perform
    if File.exists?(self.directory)
      FileUtils.rm_rf(self.directory)
    end
  end

end