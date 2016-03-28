#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do
  $running = false
end

$consecutive_errors = 0

begin
  config = Application.downloader_config
  connection = Bunny.new(config.amqp)
  connection.start
  Kernel.at_exit do
    connection.close rescue nil
  end
  Rails.logger.info "Starting AMQP listener for Downloader"
  channel = connection.create_channel
  queue = channel.queue(config.incoming_queue, durable: true)
  queue.subscribe do |delivery_info, properties, payload|
    begin
      Downloader::Request.handle_response(payload)
    rescue Exception => e
      Rails.logger.error "Failed to handle Downloader response #{payload}: #{e}"
    end
  end
rescue Exception => e
  Rails.logger.error "Unknown error starting AMQP listener for Downloader: #{e}"
end


#TODO - ultimately make the whole message receiving system more generic. It should be able to take in responses of
#various types and perhaps from various queues. Maybe just run each type of message in its own thread so as not to
#have to spawn a lot of these daemons?
while ($running) do
  begin
    AmqpConnector.connector(:medusa).reinitialize
    AmqpResponse::AmazonBackup.handle_responses
    AmqpResponse::Fixity.handle_responses
    Idb::AmqpReceiver.handle_responses if Idb::Config.instance.active?
    $consecutive_errors = 0
    sleep 60
  rescue Exception => e
    Rails.logger.error "MESSAGE RECEIVER ERROR:"
    Rails.logger.error e.to_s
    $consecutive_errors += 1
    if $consecutive_errors == 10
      MessageReceiverErrorMailer.error().deliver_now
    end
    sleep 10
  end
end

