#We leave out the partial indexes that were removed in the previous migration as they didn't seem
#to help in the way that we hoped anyway.
#Don't re-add the mtime index as that isn't used and was probably just a convenience for me in the console or something.
class ReinstateSomeIndexes < ActiveRecord::Migration
  def change
    add_index :cfs_files, :size
    add_index :cfs_files, :created_at
    add_index :cfs_files, :updated_at
  end
end
