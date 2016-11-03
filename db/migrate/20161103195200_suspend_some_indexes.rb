class SuspendSomeIndexes < ActiveRecord::Migration

  def up
    %w(true false).each do |state|
      ActiveRecord::Base.connection.execute("DROP INDEX cfs_files_fits_serialized_#{state}_ids")
    end
    remove_index :cfs_files, :mtime
    remove_index :cfs_files, :size
    remove_index :cfs_files, :created_at
    remove_index :cfs_files, :updated_at
  end
  def down
    %w(true false).each do |state|
      ActiveRecord::Base.connection.execute("CREATE INDEX cfs_files_fits_serialized_#{state}_ids ON cfs_files(id) WHERE fits_serialized is #{state};")
    end
    add_index :cfs_files, :mtime
    add_index :cfs_files, :size
    add_index :cfs_files, :created_at
    add_index :cfs_files, :updated_at
  end

end
