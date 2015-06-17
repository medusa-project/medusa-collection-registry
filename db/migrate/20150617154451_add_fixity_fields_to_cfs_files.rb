#Add fields needed for automated fixity checking
#We'll run an initial scan to populate these fields for all CfsFile objects,
#in addition to making the existing code use them as appropriate.
class AddFixityFieldsToCfsFiles < ActiveRecord::Migration
  def up
    add_column :cfs_files, :fixity_check_time, :datetime
    add_index :cfs_files, :fixity_check_time
    add_column :cfs_files, :fixity_check_status, :string
    add_index :cfs_files, :fixity_check_status
  end

  def down
    remove_column :cfs_files, :fixity_check_status
    remove_column :cfs_files, :fixity_check_time
  end
end
