require 'net_id_person_associator'
class ProductionUnit < ActiveRecord::Base
  net_id_person_association(:administrator)

  attr_accessible :address_1, :address_2, :city, :email, :notes,
                  :phone_number, :state, :title, :url, :zip

  validates_presence_of :title
  validates_uniqueness_of :title
  has_many :file_groups
  before_destroy :destroyable?

  def destroyable?
    self.file_groups.count == 0
  end

end
