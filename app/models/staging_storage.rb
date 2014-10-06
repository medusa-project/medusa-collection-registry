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

  #if there is a local path corresponding to the supplied remote path return it, otherwise nil
  def local_path_for(remote_path)
    root = self.roots.detect {|root| remote_path.match(/^#{root.remote_path}/)}
    return nil unless root
    local_path = self.class.normalize_path(remote_path.sub(/^#{root.remote_path}/, root.local_path))
    File.directory?(local_path) ? local_path : nil
  end

end