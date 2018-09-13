class AmqpAccrual::DeleteJob < Job::Base
  include AmqpConnector
  use_amqp_connector :medusa
  serialize :incoming_message

  def self.create_for(client, message)
    job = self.new(incoming_message: message, client: client)
    begin
      unless AmqpAccrual::Config.allow_delete?(client)
        job.send_delete_not_permitted_message
        return
      end
      job.save!
      Delayed::Job.enqueue(job, queue: AmqpAccrual::Config.delayed_job_queue(client), priority: Settings.delayed_job.priority.amqp_accrual_delete_job)
    rescue Exception => e
      Rails.logger.error "Failed to create Amqp Delete Job for client: #{client} message: #{message}. Error: #{e}"
      job.send_unknown_error_message(e)
    end
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

  def cfs_file_uuid
    incoming_message['uuid']
  end

  def pass_through
    incoming_message['pass_through']
  end

  def send_unknown_error_message(error)
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), unknown_error_message(error))
  end

  def destroy_file_and_answer(cfs_file)
    cfs_file.remove_from_storage
    cfs_file.destroy!
    send_success_message
  end

  def unknown_error_message(error)
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'error', error: "Unknown error: #{error}", pass_through: pass_through}
  end

  def delete_not_permitted_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'error', error: 'Deletion is not allowed for this file group.', pass_through: pass_through}
  end

  def send_delete_not_permitted_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), delete_not_permitted_message)
  end

  def wrong_file_group_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'error', error: 'File is not in the allowed file group', pass_through: pass_through}
  end

  def send_wrong_file_group_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), wrong_file_group_message)
  end

  def file_not_found_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'error', error: 'File not found', pass_through: pass_through}
  end

  def send_file_not_found_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), file_not_found_message)
  end

  def success_message
    {operation: 'delete', uuid: cfs_file_uuid,
     status: 'ok', pass_through: pass_through}
  end

  def send_success_message
    amqp_connector.send_message(AmqpAccrual::Config.outgoing_queue(client), success_message)
  end

end