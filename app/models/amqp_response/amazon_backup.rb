#Receive a response from the amazon backup server.
class AmqpResponse::AmazonBackup < AmqpResponse::Base

  def archive_ids
    self.parameter_field('archive_ids')
  end

  def pass_through_id_key
    'backup_job_id'
  end

  def pass_through_class_key
    'backup_job_class'
  end

  def self.incoming_queue
    ::AmazonBackup.incoming_queue
  end

  def self.listener_name
    'amazon backup'
  end

  def success_method
    :on_amazon_glacier_succeeded_message
  end

  def failure_method
    :on_amazon_glacier_failed_message
  end

  def unrecognized_method
    :on_amazon_glacier_unrecognized_message
  end

  def dispatch_result
    logger = Logger.new(File.join(Rails.root, 'log', 'glacier.log'))
    logger.level = Logger::DEBUG
    logger.debug("Dispatching payload: #{payload.inspect}")
    super
  end
end