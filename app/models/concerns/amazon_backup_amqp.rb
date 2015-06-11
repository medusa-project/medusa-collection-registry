require 'active_support/concern'

module AmazonBackupAmqp
  extend ActiveSupport::Concern

  included do
    delegate :incoming_queue, :outgoing_queue, to: :class
  end

  module ClassMethods
    def incoming_queue
      MedusaCollectionRegistry::Application.medusa_config['amazon']['incoming_queue']
    end

    def outgoing_queue
      MedusaCollectionRegistry::Application.medusa_config['amazon']['outgoing_queue']
    end

  end

  def send_backup_request_message
    date = self.previous_backup.try(:date)
    AmqpConnector.instance.send_message(self.outgoing_queue, create_backup_request_message(date))
  end

  def create_backup_request_message(date)
    {action: 'upload_directory',
     parameters: {directory: self.cfs_directory.path, description: self.glacier_description, date: date},
     pass_through: {backup_job_class: self.class.to_s, backup_job_id: self.id, directory: self.cfs_directory.path}}
  end

  def on_amazon_backup_succeeded_message(response)
    self.archive_ids = response.archive_ids
    self.part_count = self.archive_ids.length
    self.save!
    AmazonMailer.progress(self).deliver_now
    create_backup_completion_event
    if self.completed?
      self.job_amazon_backup.try(:destroy)
      self.workflow_ingest.try(:be_at_end)
      self.workflow_accrual_jobs.each {|job| job.try(:be_at_end)}
    end
  end

  def on_amazon_backup_failed_message(response)
    AmazonMailer.failure(self, response.error_message).deliver
  end

  def on_amazon_backup_unrecognized_message(response)
    AmazonMailer.failure.deliver(self, 'Unrecognized status code in AMQP response')
  end

end