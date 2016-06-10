class AmqpAccrual::DeleteJob < Job::Base

  def self.create_for(client, message)
    #TODO check that deletion is permitted
    job = self.new(cfs_file_uuid: message['uuid'], client: client)
    job.save!
    Delayed::Job.enqueue(job, queue: AmqpAccrual::Config.delayed_job_queue(client), priority: 30)
  rescue Exception => e
    Rails.logger.error "Failed to create Amqp Delete Job for client: #{client} message: #{message}. Error: #{e}"
    send_unknown_error_message(client, message, e)
  end

  def perform
    #TODO check that file can be found, is in the right file group
    #TODO delete file and return message
  rescue Exception => e
    Rails.logger.error("Error for Amqp Delete. Job: #{self.id}\nError: #{e}")
    raise
  end

  protected

  def self.unknown_error_message(incoming_message, error)
    {operation: 'delete', uuid: incoming_message['uuid'],
     status: 'error', error: "Unknown error: #{error}"}
  end

  def self.send_unknown_error_message(client, incoming_message, error)
    AmqpConnector.connector(:medusa).send_message(AmqpAccrual::Config.outgoing_queue(client), unknown_error_message(incoming_message, error))
  end

end