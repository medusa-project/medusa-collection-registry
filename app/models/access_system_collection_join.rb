class AccessSystemCollectionJoin < ActiveRecord::Base
  belongs_to :access_system, touch: true
  belongs_to :collection, touch: true
end
