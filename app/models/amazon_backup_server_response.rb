#Receive a response from the amazon backup server.
class AmazonBackupServerResponse < AmqpServerResponse

  def archive_ids
    self.parameter_field('archive_ids')
  end

  def pass_through_id_key
    :backup_job_id
  end

  def pass_through_class_key
    :backup_job_class
  end

  def self.incoming_queue
    AmazonBackup.incoming_queue
  end

  def success_method
    :on_amazon_backup_succeeded_message
  end

  def failure_method
    :on_amazon_backup_failed_message
  end

  def unrecognized_method
    :on_amazon_backup_unrecognized_message
  end

end