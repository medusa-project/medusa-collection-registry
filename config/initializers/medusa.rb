Application.medusa_config =
  Config.new(YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env])

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AmqpConnector.new(:medusa, Application.medusa_config.amqp(default: Hash.new).symbolize_keys)
    end
  end
else
  AmqpConnector.new(:medusa, Application.medusa_config.amqp(default: Hash.new).symbolize_keys)
end
