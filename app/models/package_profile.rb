class PackageProfile < ActiveRecord::Base
 # attr_accessible :name, :notes, :url
  has_many :file_groups

  validates_uniqueness_of :name, :allow_blank => false
end
