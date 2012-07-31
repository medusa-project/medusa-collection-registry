require 'net_id_person_associator'
class Repository < ActiveRecord::Base
  net_id_person_association(:contact)
  attr_accessible :notes, :title, :url, :address_1, :address_2, :city, :state,
                  :zip, :phone_number, :email
  has_many :collections, :dependent => :destroy

  validates_uniqueness_of :title
  validates_presence_of :title

end
