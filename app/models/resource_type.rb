class ResourceType < ActiveRecord::Base
  has_many :resource_typeable_resource_type_joins, dependent: :destroy
end
