class User < ApplicationRecord

  validates_uniqueness_of :uid, allow_blank: false
  validates :email, allow_blank: false, uniqueness: true, email: true
  has_many :workflow_accrual_jobs, :class_name => 'Workflow::AccrualJob'

  def netid
    self.uid.split('@').first
  end

  def net_id
    self.netid
  end

  def person
    Person.find_or_create_by!(email: self.email)
  end

  def superuser?
    GroupManager.instance.resolver.is_ad_superuser?(self)
  end

  def project_admin?
    GroupManager.instance.resolver.is_ad_project_admin?(self)
  end

  def medusa_admin?
    GroupManager.instance.resolver.is_ad_admin?(self)
  end

end
