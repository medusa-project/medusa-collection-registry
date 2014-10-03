require 'singleton'

class StagingStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = MedusaRails3::Application.medusa_config['staging_storage']['roots'] || []
    @roots = config_roots.collect {|root_hash| StagingStorageRoot.new(root_hash)}
  end

end