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

end