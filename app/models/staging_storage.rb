require 'singleton'

class StagingStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = MedusaRails3::Application.medusa_config['staging_storage']['roots'] || []
    @roots = config_roots.collect {|root_hash| StagingStorageRoot.new(root_hash)}
  end

  #return the path with all '\' changed to '/' and any multiples condensed to one
  def self.normalize_path(path)
    path.tr('\\', '/').gsub(/\/+/, '/')
  end

  #if one of the roots is a possible root for the given path true, otherwise false
  def root_for(path)
    root = self.roots.detect {|root| path.match(/^#{root.remote_path}/)}
    return nil unless root
    local_path = self.class.normalize_path(path.sub(/^#{root.remote_path}/, root.local_path))
    return File.directory?(local_path)
  end

end