require 'fileutils'
class Workflow::FileGroupDelete < Workflow::Base

  belongs_to :file_group
  belongs_to :requester, class_name: 'User'
  belongs_to :approver, class_name: 'User'

  before_create :cache_fields

  STATES = %w(start email_superusers wait_decision email_requester_accept email_requester_reject move_content delete_content email_requester_final_removal end)
  validates_inclusion_of :state, in: STATES, allow_blank: false

  def perform_start
    be_in_state_and_requeue('email_superusers')
  end

  def perform_email_superusers
    Workflow::FileGroupDeleteMailer.email_superusers(self).deliver_now
    be_in_state('wait_decision')
  end

  def perform_wait_decision
    unrunnable_state
  end

  def perform_email_requester_accept
    Workflow::FileGroupDeleteMailer.requester_accept(self).deliver_now
    be_in_state_and_requeue('move_content')
  end

  def perform_email_requester_reject
    Workflow::FileGroupDeleteMailer.requester_reject(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_move_content
    create_db_backup_tables
    move_physical_content
    destroy_db_objects
    be_in_state_and_requeue('delete_content')
  end

  def perform_email_requester_final_removal
    Workflow::FileGroupDeleteMailer.requester_final_removal(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_end
    destroy_queued_jobs_and_self
  end

  def approver_email
    approver.present? ? approver.email : 'Unknown'
  end

  def cache_fields
    self.cached_file_group_title ||= file_group.title
    self.cached_collection_id ||= file_group.collection_id
    self.cached_cfs_directory_id ||= file_group.cfs_directory_id
  end

  protected

  def move_physical_content
    FileUtils.mkdir_p(Settings.medusa.cfs.fg_delete_holding)
    FileUtils.move(file_group.cfs_directory.absolute_path, File.join(Settings.medusa.cfs.fg_delete_holding, file_group.id.to_s))
  end

  def destroy_db_objects
    file_group.cfs_directory.destroy_tree_from_leaves
    transaction do
      file_group.destroy!
      Event.create!(eventable: file_group.collection, key: :file_group_delete_moved, actor_email: requester.email,
                    note: "File Group #{file_group.id} - #{file_group.title} | Collection: #{file_group.collection.id}")
    end
  end

  def create_db_backup_tables

  end
  
end
