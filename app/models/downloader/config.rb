class Downloader::Config < Object

  attr_accessor :config

  def initialize(config_hash)
    self.config = config_hash.with_indifferent_access
  end

  def [](key)
    self.config[key]
  end

  def at(*keys)
    keys.inject(config) { |acc, key| acc[key] }
  end

  #map method name to key sequence or single key to retreive
  EXPOSED_VALUES = {
      root: :root,
      incoming_queue: :incoming_queue,
      outgoing_queue: :outgoing_queue,
      amqp: :amqp
  }

  EXPOSED_VALUES.each do |method_name, keys|
    define_method method_name do |default: nil|
      at(*Array.wrap(keys)) || default
    end
  end

end