class Repository < ActiveRecord::Base
  attr_accessible :notes, :title, :url, :address_1, :address_2, :city, :state,
                  :zip, :phone_number, :email, :contact_net_id
  has_many :collections, :dependent => :destroy
  belongs_to :contact, :class_name => Person

  validates_uniqueness_of :title
  validates_presence_of :title

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
