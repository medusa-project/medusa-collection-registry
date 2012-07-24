class Repository < ActiveRecord::Base
  attr_accessible :notes, :title, :url
  has_many :collections
end
