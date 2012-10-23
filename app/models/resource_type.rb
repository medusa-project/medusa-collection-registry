class ResourceType < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :collection_resource_type_joins, :dependent => :destroy
end
