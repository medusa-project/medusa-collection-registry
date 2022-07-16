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

  def self.find_or_create_local_user(name:, email:, password:)
    return nil if Rails.env.production?

    identity = Identity.find_or_create_by(name: name, email: email)
    salt = BCrypt::Engine.generate_salt
    encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    identity.password_digest = encrypted_password
    identity.update(password: password, password_confirmation: password)
    identity.save!

    return User.find_or_create_by!(uid: email, email: email)

  end

end