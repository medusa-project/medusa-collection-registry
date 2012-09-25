require 'net_id_person_associator'
class ProductionUnit < ActiveRecord::Base
  net_id_person_association(:administrator)

  attr_accessible :address_1, :address_2, :city, :email, :notes,
                  :phone_number, :state, :title, :url, :zip, :active_start_date, :active_end_date

  validates_presence_of :title
  validates_uniqueness_of :title
  validate :check_active_dates

  has_many :file_groups
  before_destroy :destroyable?

  auto_html_for :notes do
    html_escape
    link :target => "_blank"
  end

  def destroyable?
    self.file_groups.count == 0
  end

  def check_active_dates
    if self.active_end_date.present? and self.active_start_date.present? and (self.active_end_date < self.active_start_date)
      errors.add(:active_start_date, 'Start date must not be later than end date.')
      errors.add(:active_end_date, 'Start date must not be later than end date.')
    end
  end

end
