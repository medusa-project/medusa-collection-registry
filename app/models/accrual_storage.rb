require 'singleton'

class AccrualStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = Settings.storage.accrual.roots.if_blank(Array.new)
    @roots = config_roots.collect {|root_config| AccrualStorageRoot.new(root_config.to_h.stringify_keys)}
  end

  def root_named(name)
    roots.detect {|root| root.name == name}
  end

end