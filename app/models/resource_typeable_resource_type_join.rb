class ResourceTypeableResourceTypeJoin < ActiveRecord::Base
  belongs_to :resource_typeable, polymorphic: true, touch: true
  belongs_to :resource_type
end
