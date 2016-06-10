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

#handle responses from medusa-downloader
Downloader::Request.listen

#handle responses from medusa-glacier
AmqpResponse::AmazonBackup.listen

#handle responses from medusa-fixity
AmqpResponse::Fixity.listen

#handle requests from active amqp accruers
AmqpAccrual::Config.clients.each do |client|
  AmqpAccrual::Receiver.listen(client) if AmqpAccrual::Config.active?(client)
end

#nothing happens here - the listeners do all the work
while ($running) do
  begin
    sleep 60
  rescue Exception => e
    Rails.logger.error "MESSAGE RECEIVER ERROR: #{e}"
  end
end

