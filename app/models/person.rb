class Person < ActiveRecord::Base
  attr_accessible :net_id

  validates_uniqueness_of :net_id
  validates_presence_of :net_id
end
