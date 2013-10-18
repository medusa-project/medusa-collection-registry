class AccessSystemCollectionJoin < ActiveRecord::Base
  belongs_to :access_system
  belongs_to :collection
end
