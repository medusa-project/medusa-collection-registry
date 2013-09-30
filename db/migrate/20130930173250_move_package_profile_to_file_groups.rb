#the only bit of trickery here is that we want to assign the
#package profile for each collection to all of its file groups
#before removing the column from collections. The migration is
#not completely reversible, but we can at least do the columns there.
class MovePackageProfileToFileGroups < ActiveRecord::Migration
  def up
    add_column :file_groups, :package_profile_id, :integer
    add_index :file_groups, :package_profile_id
    Collection.all.each do |collection|
      if collection.package_profile_id.present?
        collection.file_groups.each do |file_group|
          file_group.update_column(:package_profile_id, collection.package_profile_id)
        end
      end
    end
    remove_column :collections, :package_profile_id
  end

  def down
    add_column :collections, :package_profile_id, :integer
    add_index :collections, :package_profile_id
    remove_column :file_groups, :package_profile_id
  end
end
