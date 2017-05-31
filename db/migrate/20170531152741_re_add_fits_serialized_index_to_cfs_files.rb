#Note that I tried this before. I think at that point the ratio of true/false was
#too even for postgres to use the index well, but now that most files have FITS
#it works a lot better
class ReAddFitsSerializedIndexToCfsFiles < ActiveRecord::Migration[5.0]
  INDEX_NAME = 'idx_cfs_files_fits_serialized'
  def up
    sql = "CREATE INDEX IF NOT EXISTS #{INDEX_NAME}  ON cfs_files (id) WHERE NOT fits_serialized"
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "DROP INDEX #{INDEX_NAME}"
    ActiveRecord::Base.connection.execute(sql)
  end

end
