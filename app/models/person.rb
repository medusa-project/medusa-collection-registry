class Person < ActiveRecord::Base
  validates_uniqueness_of :net_id
  validates_presence_of :net_id
end
