class ProductionUnit < ActiveRecord::Base
  attr_accessible :address_1, :address_2, :city, :email, :notes,
                  :phone_number, :state, :title, :url, :zip,
                  :administrator_net_id

  validates_presence_of :title
  validates_uniqueness_of :title
  has_many :file_groups
  belongs_to :administrator, :class_name => Person
  before_destroy :destroyable?

  def destroyable?
    self.file_groups.count == 0
  end

  def administrator_net_id
    self.administrator.try(:net_id)
  end

  def administrator_net_id=(net_id)
    net_id.strip!
    if net_id.blank?
      self.administrator = nil
    else
      self.administrator = Person.find_or_create_by_net_id(net_id)
    end
  end

end
