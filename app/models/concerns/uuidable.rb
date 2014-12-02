require 'active_support/concern'

module Uuidable
  extend ActiveSupport::Concern

  included do
    has_one :medusa_uuid, dependent: :destroy, as: :uuidable
    after_create :ensure_uuid
  end

  def ensure_uuid
    unless self.medusa_uuid.present?
      MedusaUuid.generate_for(self)
    end
    self.medusa_uuid(true)
  end

  def uuid
    self.medusa_uuid.try(:uuid)
  end

  #This method is needed to get a predictable uuid for testing, but shouldn't be used otherwise
  if Rails.env.test?
    def uuid=(uuid)
      self.medusa_uuid.destroy if self.medusa_uuid
      MedusaUuid.create!(uuid: uuid, uuidable: self)
    end
  end

  def handle
    self.uuid ? "10111/MEDUSA:#{self.uuid}" : nil
  end

end