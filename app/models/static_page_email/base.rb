class StaticPageEmail::Base
  include ActiveModel::Validations

  attr_accessor :name, :email
  validates_presence_of :name, :email
  validates :email, email: true

  def persisted?
    false
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def send_emails
    prefix = self.class.to_s.demodulize.underscore
    StaticPageMailer.send("#{prefix}_internal", self).deliver_now
    StaticPageMailer.send("#{prefix}_confirmation", self).deliver_now
  end

end