Application.medusa_config =
  Config.new(YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env])

AmqpConnector.new(:medusa, Application.medusa_config.amqp(default: Hash.new).symbolize_keys)