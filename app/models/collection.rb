require 'net_id_person_associator'
class Collection < ActiveRecord::Base
  net_id_person_association(:contact)
  attr_accessible :access_url, :description, :end_date, :file_package_summary, :notes,
                  :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement,
                  :start_date, :title, :content_type_id, :access_system_ids

  belongs_to :repository
  belongs_to :content_type
  has_many :assessments, :dependent => :destroy
  has_many :file_groups, :dependent => :destroy
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :access_systems, :through => :access_system_collection_joins

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :repository_id

end
