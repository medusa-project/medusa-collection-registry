class StorageManager

  attr_accessor :main_root, :amqp_roots, :project_staging_root, :accrual_roots,
                :fits_root, :tmpdir

  def initialize
    initialize_main_storage
    initialize_amqp_storage
    initialize_project_staging_storage
    initialize_accrual_storage
    initialize_fits_root
    initialize_tmpdir
  end

  def initialize_main_storage
    root_config = Settings.storage.main_root.to_h
    self.main_root = MedusaStorage::RootFactory.create_root(root_config)
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

  def amqp_root_at(name)
    amqp_roots.at(name)
  end

  def initialize_tmpdir
    self.tmpdir = Settings.storage.tmpdir.if_blank(ENV['TMPDIR'])
  end

end