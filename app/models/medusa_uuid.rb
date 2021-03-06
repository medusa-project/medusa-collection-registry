require 'utils/luhn'

class MedusaUuid < ApplicationRecord
  belongs_to :uuidable, polymorphic: true

  validates_uniqueness_of :uuidable_type, scope: :uuidable_id
  validates_uniqueness_of :uuid, allow_blank: false
  validates_each :uuid do |record, attr, value|
    record.errors.add attr, 'is not a valid uuid' unless Utils::Luhn.verify(value)
  end

  searchable do
    integer :model_id, using: :id
    text :uuid
    string :uuid
  end

  def self.generate_for(uuidable)
    self.create!(uuid: generate, uuidable: uuidable)
  end

  def self.generate
    Utils::Luhn.generate_checked_uuid
  end

end
