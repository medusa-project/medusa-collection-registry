class RemovePackageProfiles < ActiveRecord::Migration[5.1]
  def change
    drop_table :package_profiles
    remove_column :file_groups, :package_profile_id
  end
end
