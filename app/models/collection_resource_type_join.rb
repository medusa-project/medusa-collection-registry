class CollectionResourceTypeJoin < ActiveRecord::Base
  #attr_accessible :collection_id, :resource_type_id

  belongs_to :collection
  belongs_to :resource_type
end
