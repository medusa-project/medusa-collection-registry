class Job::Report::CfsDirectoryMap < ApplicationRecord
  belongs_to :user
  belongs_to :cfs_directory
end
