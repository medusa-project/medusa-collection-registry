class CollectionObjectTypeJoin < ActiveRecord::Base
  attr_accessible :collection_id, :object_type_id
  belongs_to :collection
  belongs_to :object_type
end
