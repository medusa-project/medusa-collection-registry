class Job::Report::CfsDirectoryManifest < ApplicationRecord
  belongs_to :user
  belongs_to :cfs_directory
end
