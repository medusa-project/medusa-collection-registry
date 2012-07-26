class ProductionUnit < ActiveRecord::Base
  attr_accessible :address_1, :address_2, :city, :email, :notes, :phone_number, :state, :title, :url, :zip
end
