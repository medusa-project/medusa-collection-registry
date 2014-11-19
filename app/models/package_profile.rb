class PackageProfile < ActiveRecord::Base
  has_many :file_groups

  validates_uniqueness_of :name, allow_blank: false
end
