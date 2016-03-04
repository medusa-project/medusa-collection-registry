class Config < Object

  attr_accessor :config

  def initialize(config_hash)
    self.config = config_hash.with_indifferent_access
  end

  def [](key)
    self.config[key]
  end

  def at(*keys)
    keys.inject(config) {|acc, key| acc[key]}
  end

end