class AccessSystemCollectionJoin < ActiveRecord::Base
  #attr_accessible :access_system_id, :collection_id
  belongs_to :access_system
  belongs_to :collection
end
