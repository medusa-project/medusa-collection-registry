class Job::FitsContentTypeBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :content_type
end
