class User < ActiveRecord::Base

  validates_uniqueness_of :uid, allow_blank: false
  validates :email, allow_blank: false, uniqueness: true, email: true

  def netid
    self.uid.split('@').first
  end

  def net_id
    self.netid
  end

  def person
    Person.find_or_create_by(email: self.email)
  end

end
