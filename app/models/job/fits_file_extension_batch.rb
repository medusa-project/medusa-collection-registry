class Job::FitsFileExtensionBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :file_extension
end
