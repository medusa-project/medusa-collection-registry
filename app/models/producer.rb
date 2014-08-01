require 'email_person_associator'
class Producer < ActiveRecord::Base
  include ActiveDateChecker

  email_person_association(:administrator)

  validates_presence_of :title
  validates_uniqueness_of :title
  validate :check_active_dates

  has_many :file_groups
  before_destroy :destroyable?

  auto_html_for :notes do
    html_escape
    link :target => '_blank'
    simple_format
  end

  def destroyable?
    self.file_groups.count == 0
  end

  def collections
    self.file_groups.includes(:collection).collect {|group| group.collection}.uniq
  end

end
