class AccessSystem < ActiveRecord::Base
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :collections, :through => :access_system_collection_joins

  validates :name, presence: true
end
