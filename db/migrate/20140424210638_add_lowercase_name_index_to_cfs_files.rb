class AddLowercaseNameIndexToCfsFiles < ActiveRecord::Migration

  #This is probably Postgres specific
  def up
    ActiveRecord::Base.connection.execute('CREATE INDEX idx_cfs_files_lower_name ON cfs_files(lower(name))')
  end

  def down
    ActiveRecord::Base.connection.execute('DROP INDEX idx_cfs_files_lower_name')
  end

end
