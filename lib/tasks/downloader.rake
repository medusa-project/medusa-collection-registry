# frozen_string_literal: true

require "rake"
require "bunny"
require "json"

namespace :downloader do
  desc "get and handle messages from downloader"
  task get_downloader_messages: :environment do
    puts "inside get_downloader_messages rake task"
    config = Settings.downloader
    puts config
    loop do
      AmqpHelper::Connector[:downloader].with_message(config.incoming_queue) do |payload|
        puts payload
        exit if payload.nil?
        Downloader::Request.handle_response(payload)
      end
    end

  end
end