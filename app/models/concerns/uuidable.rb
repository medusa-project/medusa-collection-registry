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
    self.reload_medusa_uuid
  end

  def uuid
    self.medusa_uuid.try(:uuid)
  end

  #This method is needed to get a predictable uuid for testing and when we have a
  #pre-existing uuid we want to use
  def uuid=(uuid)
    if self.medusa_uuid
      unless self.medusa_uuid.uuid == uuid
        self.medusa_uuid.uuid = uuid
        self.medusa_uuid.save!
      end
    else
      MedusaUuid.create!(uuid: uuid, uuidable: self)
    end

  end

  def handle
    self.uuid ? "10111/MEDUSA:#{self.uuid}" : nil
  end

end