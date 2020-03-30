class StorageManager

  attr_accessor :main_root, :main_root_rclone, :main_root_backup, :amqp_roots, :project_staging_root, :accrual_roots,
                :fits_root, :tmpdir, :globus_endpoints

  def initialize
    initialize_main_storage
    initialize_main_storage_rclone
    initialize_main_storage_backup
    initialize_amqp_storage
    initialize_project_staging_storage
    initialize_accrual_storage
    initialize_fits_root
    initialize_tmpdir
    initialize_globus_endpoints
  end

  def initialize_main_storage
    root_config = Settings.storage.main_root.to_h
    self.main_root = MedusaStorage::RootFactory.create_root(root_config)
  end

  def initialize_main_storage_rclone
    if Settings.storage.main_root_rclone.present?
      rclone_config = Settings.storage.main_root_rclone.to_h
      self.main_root_rclone = MedusaStorage::RootFactory.create_root(rclone_config)
    else
      self.main_root_rclone = nil
    end
  end

  def initialize_main_storage_backup
    root_config = Settings.storage.main_root_backup
    self.main_root_backup = if root_config.present?
                              MedusaStorage::RootFactory.create_root(root_config.to_h)
                            else
                              nil
                            end
  end

  def initialize_amqp_storage
    amqp_config = Settings.storage.amqp.collect(&:to_h)
    self.amqp_roots = MedusaStorage::RootSet.new(amqp_config)
  end

  def initialize_project_staging_storage
    root_config = Settings.storage.project_staging.to_h
    self.project_staging_root = MedusaStorage::RootFactory.create_root(root_config)
  end

  def initialize_accrual_storage
    accrual_config = Settings.storage.accrual.collect(&:to_h)
    self.accrual_roots = MedusaStorage::RootSet.new(accrual_config)
  end

  def initialize_fits_root
    fits_config = Settings.storage.fits.to_h
    self.fits_root = MedusaStorage::RootFactory.create_root(fits_config)
  end

  def self.amqp_root_at(name)
    amqp_roots.at(name)
  end

  def self.globus_endpoint_at(name)
    globus_endpoints[name]
  end

  def initialize_tmpdir
    self.tmpdir = Settings.storage.tmpdir.if_blank(ENV['TMPDIR'])
  end

  def initialize_globus_endpoints
    endpoint_config = Settings.globus.accrual.collect(&:to_h)
    self.globus_endpoints = Hash.new
    endpoint_config.each do |endpoint|
      self.globus_endpoints[endpoint[:name]] = endpoint
    end
  end

end