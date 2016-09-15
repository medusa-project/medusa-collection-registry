class PackageProfile < ActiveRecord::Base
  has_many :file_groups
  has_many :collections, -> {distinct}, through: :file_groups

  validates_uniqueness_of :name, allow_blank: false
end
