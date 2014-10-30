#Receive a response from the amazon backup server.
#Usually we'll make this object and call dispatch_result, which will
#invoke a method on the object that scheduled the backup with this
#response as an argument. That object can then take care of its business
#as necessary.
class AmazonBackupServerResponse < Object

  attr_accessor :payload

  def initialize(amqp_raw_payload)
    self.payload = JSON.parse(amqp_raw_payload)
  end

  def status
    self.payload['status']
  end

  def error_message
    self.payload['error_message']
  end

  def pass_through(field)
    self.payload['pass_through'][field.to_s]
  end

  def archive_ids
    self.payload['parameters']['archive_ids']
  end

  def backup_handler
    klass = Kernel.const_get(self.pass_through(:backup_job_class))
    id = self.pass_through(:backup_job_id)
    klass.find(id)
  end

  def dispatch_result
    case self.status
      when 'success'
        self.backup_handler.on_amazon_backup_succeeded_message(self)
      when 'failure'
        self.backup_handler.on_amazon_backup_failed_message(self)
      else
        self.backup_handler.on_amazon_backup_unrecognized_message(self)
    end
  end

  def self.handle_responses
    AmqpConnector.instance.with_queue(AmazonBackup.incoming_queue) do |queue|
      while true
        delivery_info, properties, raw_payload = queue.pop
        break unless raw_payload
        response = self.new(raw_payload)
        response.dispatch_result
      end
    end
  end

end