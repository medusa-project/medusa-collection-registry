class Workflow::AccrualJob < ActiveRecord::Base
  belongs_to :cfs_directory, touch: true
  belongs_to :user, touch: true

  has_many :workflow_accrual_directories, :class_name => 'Workflow::AccrualDirectory'
  has_many :workflow_accrual_files, :class_name => 'Workflow::AccrualFile'

  validates_presence_of :cfs_directory_id, :user_id
  validates_uniqueness_of :staging_path, scope: :cfs_directory_id

end
