class RenameCollectionResourceTypeJoinToResourceTypeableResourceTypeJoin < ActiveRecord::Migration
  #The stuff with the index is because otherwise the name is too long
  def change
    rename_table :collection_resource_type_joins, :resource_typeable_resource_type_joins
    remove_index :resource_typeable_resource_type_joins, :collection_id
    rename_column :resource_typeable_resource_type_joins, :collection_id, :resource_typeable_id
    add_index :resource_typeable_resource_type_joins, :resource_typeable_id, name: :index_resource_typeable_id
    add_column :resource_typeable_resource_type_joins, :resource_typeable_type, :string
    ResourceTypeableResourceTypeJoin.all.each do |join|
      join.resource_typeable_type = 'Collection'
      join.save
    end
  end
end
