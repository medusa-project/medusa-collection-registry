class Person < ActiveRecord::Base
  validates :net_id, presence: true, uniqueness: true, email: true
end
