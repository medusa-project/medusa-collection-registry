class RemoveResourceTypeFromFileGroups < ActiveRecord::Migration[5.1]
  def change
    ResourceTypeableResourceTypeJoin.where(resource_typeable_type: 'FileGroup').delete_all
  end
end
