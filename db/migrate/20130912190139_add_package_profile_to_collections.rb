class AddPackageProfileToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :package_profile_id, :integer
    add_index :collections, :package_profile_id
  end
end
