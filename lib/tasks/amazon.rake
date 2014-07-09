require 'rake'

namespace :amazon do
  desc 'Handle and incoming messages from the medusa-glacier server'
  task :handle_responses => :environment do
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    queue = channel.queue(AmazonBackup.incoming_queue, durable: true)
    while true
      delivery_info, properties, raw_payload = queue.pop
      break unless raw_payload
      puts "Handling message: #{raw_payload}"
      #check status - if okay then find and callback to backup
      #if error then report via email
      payload = JSON.parse(raw_payload)
      amazon_backup = AmazonBackup.find(payload['pass_through']['amazon_backup_id'])
      status = payload ['status']
      error_message = payload['error_message']
      case status
        when 'success'
          part = payload['pass_through']['part']
          archive_id = payload['parameters']['archive_id']
          amazon_backup.receive_backup_response_message(part, archive_id)
        when 'failure'
          AmazonMailer.failure(amazon_backup, error_message).deliver
        else
          AmazonMailer.failure.deliver(amazon_backup, 'Unrecognized status code in AMQP response')
      end
    end
  end
end

# def initialize
#     self.connection = Bunny.new
#     self.connection.start
#     self.channel = self.connection.create_channel
#     self.exchange = self.channel.default_exchange
#   end
#
#   def send_request
#     request = {action: 'upload_directory', parameters: {directory: '/home/hading/tmp/upload', description: 'Test upload'},
#                pass_through: {x: 'x', y: 'y'}}
#     self.exchange.publish(request.to_json, :routing_key => 'medusa_to_glacier', :persistent => true)
#   end
#
#   def get_response
#     queue = self.channel.queue('glacier_to_medusa', durable: true)
#     delivery_info, properties, payload = queue.pop
#     return delivery_info, properties, payload
#   end