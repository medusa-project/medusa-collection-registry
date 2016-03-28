Application.downloader_config =
    Downloader::Config.new(YAML.load_file(File.join(Rails.root, 'config', 'downloader.yml'))[Rails.env])

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpConnector.new(:downloader, Application.downloader_config.amqp(default: Hash.new).symbolize_keys)
      # begin
      #   config = Application.downloader_config
      #   connection = Bunny.new(config.amqp)
      #   connection.start
      #   Kernel.at_exit do
      #     connection.close rescue nil
      #   end
      #   Rails.logger.info "Starting AMQP listener for Downloader"
      #   channel = connection.create_channel
      #   queue = channel.queue(config.incoming_queue, durable: true)
      #   queue.subscribe do |delivery_info, properties, payload|
      #     begin
      #       Downloader::Request.handle_response(payload)
      #     rescue Exception => e
      #       Rails.logger.error "Failed to handle Downloader response #{payload}: #{e}"
      #     end
      #   end
      # rescue Exception => e
      #   Rails.logger.error "Unknown error starting AMQP listener for Downloader: #{e}"
      # end
    end
  end
else
  AmqpConnector.new(:downloader, Application.downloader_config.amqp(default: Hash.new).symbolize_keys)
end