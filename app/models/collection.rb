class Collection < ActiveRecord::Base
  attr_accessible :access_url, :description, :end_date, :file_package_summary, :notes,
                  :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement,
                  :start_date, :title, :content_type_id
  belongs_to :repository
  belongs_to :content_type
  has_many :assessments, :dependent => :destroy
  has_many :file_groups, :dependent => :destroy

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :repository_id
end
