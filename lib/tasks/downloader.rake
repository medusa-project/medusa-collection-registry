# frozen_string_literal: true

require "rake"
require "bunny"
require "json"

namespace :downloader do
  desc "fetch and initiate handling of messages from downloader"
  task fetch_downloader_messages: :environment do
    config = Settings.downloader
    loop do
      AmqpHelper::Connector[:downloader].with_message(config.incoming_queue) do |payload|
        Rails.logger.warn "Message from Downloader:"
        Rails.logger.warn payload
        exit if payload.nil?
        Downloader::Request.handle_response(payload)
      end
    end
  end
end