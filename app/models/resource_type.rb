class ResourceType < ActiveRecord::Base
  has_many :collection_resource_type_joins, dependent: :destroy
end
