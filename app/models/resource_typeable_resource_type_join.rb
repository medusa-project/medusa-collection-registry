#This used to be polymorphic, but as I write it applies only to collections, so if we wanted we could
# simplify that out.
class ResourceTypeableResourceTypeJoin < ApplicationRecord
  belongs_to :resource_typeable, polymorphic: true, touch: true
  belongs_to :resource_type
end
