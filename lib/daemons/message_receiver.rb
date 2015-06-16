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

#TODO - ultimately make the whole message receiving system more generic. It should be able to take in responses of
#various types and perhaps from various queues. Maybe just run each type of message in its own thread so as not to
#have to spawn a lot of these daemons?
while ($running) do
  begin
    AmqpConnector.instance.initialize
    AmqpResponse::AmazonBackup.handle_responses
    AmqpResponse::Fixity.handle_responses
    sleep 60
  rescue Exception => e
    Rails.logger.error "MESSAGE RECEIVER ERROR:"
    Rails.logger.error e.to_s
    sleep 10
  end
end

