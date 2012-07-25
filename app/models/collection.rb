class Collection < ActiveRecord::Base
  attr_accessible :access_url, :description, :end_date, :file_package_summary, :notes, :ongoing, :published, :repository_id, :rights_restrictions, :rights_statement, :start_date, :title
  belongs_to :repository
  has_many :assessments
end
