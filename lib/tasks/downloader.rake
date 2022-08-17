# frozen_string_literal: true

require "rake"
require "bunny"
require "json"

namespace :downloader do
  desc "get and handle messages from downloader"
  task get_downloader_messages: :environment do
    config = Settings.downloader

    loop do
      AmqpHelper::Connector[:databank].with_message(config.incoming_queue) do |payload|
        exit if payload.nil?
        Downloader.Request.handle_response(payload)
      end
    end

  end
end