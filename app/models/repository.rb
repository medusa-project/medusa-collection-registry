class Repository < ActiveRecord::Base
  attr_accessible :notes, :title, :url, :address_1, :address_2, :city, :state,
      :zip, :phone_number, :email
  has_many :collections
end
