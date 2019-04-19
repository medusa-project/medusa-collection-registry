class Job::Report::CfsDirectoryManifest < ApplicationRecord
  belongs_to :user
  belongs_to :cfs_directory

  def self.create_for(user, cfs_directory)
    Delayed::Job.enqueue(self.create!(user: user, cfs_directory: cfs_directory), queue: 'short')
  end

  def perform
    report = Report::CfsDirectoryManifest.new(cfs_directory)
    io = StringIO.new
    report.generate_tsv(io)
    ReportMailer.cfs_directory_manifest(self, io).deliver_now
  end



end
