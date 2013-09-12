class PackageProfile < ActiveRecord::Base
  attr_accessible :name, :notes, :url
  has_many :collections

  validates_uniqueness_of :name, :allow_blank => false
end
