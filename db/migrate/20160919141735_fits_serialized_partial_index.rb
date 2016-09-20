class FitsSerializedPartialIndex < ActiveRecord::Migration
  def up
    remove_index :cfs_files, [:fits_serialized, :id]
    %w(true false).each do |state|
      ActiveRecord::Base.connection.execute("CREATE INDEX cfs_files_fits_serialized_#{state}_ids ON cfs_files(id) WHERE fits_serialized is #{state};")
    end
  end
  def down
    add_index :cfs_files, [:fits_serialized, :id]
    %w(true false).each do |state|
      ActiveRecord::Base.connection.execute("DROP INDEX cfs_files_fits_serialized_#{state}_ids")
    end
  end
end
