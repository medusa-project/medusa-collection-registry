class Producer < ActiveRecord::Base
  include ActiveDateChecker
  include EmailPersonAssociator
  include MedusaAutoHtml

  email_person_association(:administrator)

  validates_presence_of :title
  validates_uniqueness_of :title
  validate :check_active_dates

  has_many :file_groups
  before_destroy :destroyable?

  standard_auto_html :notes

  def destroyable?
    self.file_groups.count == 0
  end

  def collections
    self.file_groups.includes(:collection).collect {|group| group.collection}.uniq
  end

end
