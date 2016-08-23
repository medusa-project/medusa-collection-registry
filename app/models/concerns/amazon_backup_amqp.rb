require 'active_support/concern'

module AmazonBackupAmqp
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, :outgoing_queue, to: :class
  end

  module ClassMethods
    def incoming_queue
      Settings.medusa.amazon.incoming_queue
    end

    def outgoing_queue
      Settings.medusa.amazon.outgoing_queue
    end

  end

  def send_backup_request_message
    date = self.previous_backup.try(:date)
    AmqpConnector.connector(:medusa).send_message(self.outgoing_queue, create_backup_request_message(date))
  end

  def create_backup_request_message(date)
    {action: 'upload_directory',
     parameters: {directory: self.cfs_directory.path, description: self.glacier_description, date: date},
     pass_through: {backup_job_class: self.class.to_s, backup_job_id: self.id, directory: self.cfs_directory.path}}
  end

  def on_amazon_glacier_succeeded_message(response)
    case response.action
      when 'upload_directory'
        self.archive_ids = response.archive_ids
        self.part_count = self.archive_ids.length
        self.save!
        AmazonMailer.progress(self).deliver_now
        create_backup_completion_event
        if self.completed?
          self.job_amazon_backup.try(:destroy)
          self.workflow_ingest.try(:complete_current_action)
          self.workflow_accrual_jobs.each { |job| job.try(:complete_current_action) }
        end
      when 'delete_archive'
        archive_id = response.parameter_field(:archive_id)
        Rails.logger.info "Deleted Amazon Glacier archive #{archive_id}"
        self.archive_ids.delete(archive_id)
        self.save!
        if self.archive_ids.blank?
          Rails.logger.info "Deleting Amazon Backup #{self.id}. All corresponding archives have been deleted."
          self.destroy!
        end
      else
        raise RuntimeError, "Unrecognized AMQP action #{response.action} for amazon backup"
    end
  end

  def on_amazon_glacier_failed_message(response)
    AmazonMailer.failure(self, response.error_message).deliver
  end

  def on_amazon_glacier_unrecognized_message(response)
    AmazonMailer.failure.deliver(self, 'Unrecognized status code in AMQP response')
  end

  def delete_archives_and_self
    if self.archive_ids.present?
      self.archive_ids.each do |archive_id|
        self.send_delete_request_message(archive_id)
      end
    end
  end

  def create_delete_request_message(archive_id)
    {action: 'delete_archive',
     parameters: {archive_id: archive_id},
     pass_through: {backup_job_class: self.class.to_s, backup_job_id: self.id}}
  end

  def send_delete_request_message(archive_id)
    AmqpConnector.connector(:medusa).send_message(self.outgoing_queue, create_delete_request_message(archive_id))
  end

end