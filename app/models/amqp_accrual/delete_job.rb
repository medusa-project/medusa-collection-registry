class AmqpAccrual::DeleteJob < Job::Base
  include AmqpConnector
  use_amqp_connector :medusa

  def self.create_for(client, message)
    unless AmqpAccrual::Config.allow_delete?(client)
      send_delete_not_permitted_message(client, message)
      return
    end
    job = self.new(cfs_file_uuid: message['uuid'], client: client)
    job.save!
    Delayed::Job.enqueue(job, queue: AmqpAccrual::Config.delayed_job_queue(client), priority: 30)
  rescue Exception => e
    Rails.logger.error "Failed to create Amqp Delete Job for client: #{client} message: #{message}. Error: #{e}"
    send_unknown_error_message(client, message, e)
  end

  def perform
    medusa_uuid = MedusaUuid.find_by(uuid: self.cfs_file_uuid)
    unless medusa_uuid.present?
      send_file_not_found_message and return
    end
    uuidable = medusa_uuid.uuidable
    unless uuidable.is_a?(CfsFile)
      send_file_not_found_message and return
    end
    unless uuidable.file_group == AmqpAccrual::Config.file_group(client)
      send_wrong_file_group_message and return
    end
    destroy_file_and_answer(uuidable)
  rescue Exception => e
    Rails.logger.error("Error for Amqp Delete. Job: #{self.id}\nError: #{e}")
    raise
  end

  protected

  def destroy_file_and_answer(cfs_file)
    cfs_file.remove_from_filesystem
    cfs_file.destroy!
    send_success_message
  end

  def self.unknown_error_message(incoming_message, error)
    {operation: 'delete', uuid: incoming_message['uuid'],
     status: 'error', error: "Unknown error: #{error}"}
  end

  def self.send_unknown_error_message(client, incoming_message, error)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), unknown_error_message(incoming_message, error))
  end

  def self.delete_not_permitted_message(incoming_message)
    {operation: 'delete', uuid: incoming_message['uuid'],
     status: 'error', error: 'Deletion is not allowed for this file group.'}
  end

  def self.send_delete_not_permitted_message(client, incoming_message)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), delete_not_permitted_message(incoming_message))
  end

  def wrong_file_group_message
    {operation: 'delete', uuid: cfs_file_uuid,
    status: 'error', error: 'File is not in the allowed file group'}
  end

  def send_wrong_file_group_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), wrong_file_group_message)
  end

  def file_not_found_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'error', error: 'File not found'}
  end

  def send_file_not_found_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), file_not_found_message)
  end

  def success_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'ok'}
  end

  def send_success_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), success_message)
  end

end