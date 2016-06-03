class Config < Object

  attr_accessor :config

  def initialize(config_hash)
    self.config = config_hash.with_indifferent_access
  end

  def [](key)
    self.config[key]
  end

  def at(*keys)
    keys.inject(config) {|acc, key| acc[key]}
  end

  #map method name to key sequence or single key to retreive
  EXPOSED_VALUES = {
      basic_auth_credentials: :basic_auth,
      public_view_on?: :public_view_on,
      iiif_config: :iiif,
      server_url: :server,
      feedback_email: %i(email feedback),
      dev_email: %i(email dev),
      noreply_email: %i(email noreply),
      admin_email: %i(email admin),
      accrual_storage_roots: %i(accrual_storage roots),
      amqp: :amqp,
      cfs: :cfs,
      cfs_export_root: %i(cfs export_root),
      cfs_export_autoclean: %i(cfs export_autoclean),
      ldap: :ldap,
      staging_storage_roots: %i(staging_storage roots),
      book_tracker_import_path: %i(book_tracker import_path),
      book_tracker_library_nuc_code: %i(book_tracker library_nuc_code),
      amazon_incoming_queue: %i(amazon incoming_queue),
      amazon_outgoing_queue: %i(amazon outgoing_queue),
      fixity_server_incoming_queue: %i(fixity_server incoming_queue),
      fixity_server_outgoing_queue: %i(fixity_server outgoing_queue),
      medusa_users_group: :medusa_users_group,
      medusa_admins_group: :medusa_admins_group,
      fits_batch_size: :fits_batch_size,
      fits_server_url: :fits_server_url,
      fits_storage: :fits_storage,
      fits_binary: :fits_binary
  }

  EXPOSED_VALUES.each do |method_name, keys|
    define_method method_name do |default: nil|
      at(*Array.wrap(keys)) || default
    end
  end

end