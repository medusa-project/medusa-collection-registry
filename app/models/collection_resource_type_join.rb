class CollectionResourceTypeJoin < ActiveRecord::Base
  belongs_to :collection, touch: true
  belongs_to :resource_type, touch: true
end
