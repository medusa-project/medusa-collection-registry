class ConvertCfsRoots < ActiveRecord::Migration
  def up
    CfsRoot.instance.available_roots
    BitLevelFileGroup.all.each do |file_group|
      if file_group.cfs_root.present? and file_group.cfs_directory_id.blank?
        cfs_root_directory = CfsDirectory.find_by(:path => file_group.cfs_root, :parent_cfs_directory_id => nil)
        raise "Unable to find cfs root directory with path #{file_group.cfs_root}" unless cfs_root_directory
        file_group.cfs_directory = cfs_root_directory
        file_group.save!
      end
    end
  end

  def down

  end

end
