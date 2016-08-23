require 'singleton'

class StagingStorage < Object
  include Singleton

  attr_reader :roots

  def initialize
    config_roots = Settings.storage.staging.roots.if_blank(Array.new)
    @roots = config_roots.collect {|root_config| StagingStorageRoot.new(root_config.to_h.stringify_keys)}
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