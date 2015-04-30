require 'singleton'

class StagingStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = MedusaCollectionRegistry::Application.medusa_config['staging_storage']['roots'] || []
    @roots = config_roots.collect {|root_hash| StagingStorageRoot.new(root_hash)}
  end

  def root_named(name)
    roots.detect {|root| root.name == name}
  end

  #return the path with all '\' changed to '/', any multiples condensed to one, and any trailing '/' removed
  def self.normalize_path(path)
    path.tr('\\', '/').gsub(/\/+/, '/').gsub(/\/+$/, '')
  end

  #if there is a local path corresponding to the supplied remote path return it, otherwise nil
  #Note the with all the '/' and '\' one finds in pathnames we have to be a little careful here.
  def local_path_for(remote_path)
    root = self.roots.detect {|root| remote_path.starts_with?(root.remote_path)}
    return nil unless root
    local_path = self.class.normalize_path(remote_path.sub(/^#{Regexp.quote(root.remote_path)}/, root.local_path))
    File.directory?(local_path) ? local_path : nil
  end

end