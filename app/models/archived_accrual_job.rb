class ArchivedAccrualJob < ApplicationRecord
  belongs_to :user
  belongs_to :file_group
  belongs_to :amazon_backup
  belongs_to :cfs_directory

  validates_presence_of :user_id, :cfs_directory_id, :staging_path, :workflow_accrual_job_id
  validates_inclusion_of :state, in: %w(completed aborted), allow_blank: false
end