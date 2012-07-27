class ProductionUnit < ActiveRecord::Base
  attr_accessible :address_1, :address_2, :city, :email, :notes, :phone_number, :state, :title, :url, :zip

  validates_presence_of :title
  validates_uniqueness_of :title
end
