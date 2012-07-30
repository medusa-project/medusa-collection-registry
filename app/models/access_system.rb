class AccessSystem < ActiveRecord::Base
  attr_accessible :name
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :collections, :through => :access_system_collection_joins
end
