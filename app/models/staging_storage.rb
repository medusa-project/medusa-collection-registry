class StagingStorage < Storage

  def initialize
    super(config_roots: Settings.storage.staging.roots.if_blank(Array.new))
  end

end