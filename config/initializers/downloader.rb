Application.downloader_config =
    Downloader::Config.new(YAML.load_file(File.join(Rails.root, 'config', 'downloader.yml'))[Rails.env])

AmqpConnector.new(:downloader, Application.downloader_config.amqp(default: Hash.new).symbolize_keys)

# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     if forked
#       AmqpConnector.new(:downloader, Application.downloader_config.amqp(default: Hash.new).symbolize_keys)
#     end
#   end
# else
#   AmqpConnector.new(:downloader, Application.downloader_config.amqp(default: Hash.new).symbolize_keys)
# end