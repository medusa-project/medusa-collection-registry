class CollectionResourceTypeJoin < ActiveRecord::Base
  belongs_to :collection
  belongs_to :resource_type
end
