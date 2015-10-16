require 'singleton'

class AccrualStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = MedusaCollectionRegistry::Application.medusa_config['accrual_storage']['roots'] || []
    @roots = config_roots.collect {|root_hash| AccrualStorageRoot.new(root_hash)}
  end

  def root_named(name)
    roots.detect {|root| root.name == name}
  end

end