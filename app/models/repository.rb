require 'net_id_person_associator'
class Repository < ActiveRecord::Base
  net_id_person_association(:contact)
  attr_accessible :notes, :title, :url, :address_1, :address_2, :city, :state,
                  :zip, :phone_number, :email, :active_start_date, :active_end_date
  has_many :collections, :dependent => :destroy

  validates_uniqueness_of :title
  validates_presence_of :title
  validate :check_active_dates

  auto_html_for :notes do
    html_escape
    link :target => "_blank"
    simple_format
  end

  def total_size
    self.collections.collect {|c| c.total_size}.sum
  end

  def check_active_dates
    if self.active_end_date.present? and self.active_start_date.present? and (self.active_end_date < self.active_start_date)
      errors.add(:active_start_date, 'Start date must not be later than end date.')
      errors.add(:active_end_date, 'Start date must not be later than end date.')
    end
  end

end
