class Collection < ActiveRecord::Base
  attr_accessible :access_url, :description, :end_date, :file_package_summary, :notes,
                  :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement,
                  :start_date, :title, :content_type_id, :access_system_ids, :contact_net_id

  belongs_to :repository
  belongs_to :content_type
  has_many :assessments, :dependent => :destroy
  has_many :file_groups, :dependent => :destroy
  has_many :access_system_collection_joins, :dependent => :destroy
  has_many :access_systems, :through => :access_system_collection_joins
  belongs_to :contact, :class_name => Person

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :repository_id

  def contact_net_id
    self.contact.try(:net_id)
  end

  def contact_net_id=(net_id)
    net_id.strip!
    if net_id.blank?
      self.contact = nil
    else
      self.contact = Person.find_or_create_by_net_id(net_id)
    end
  end

end
