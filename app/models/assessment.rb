class Assessment < ApplicationRecord
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:author)

  belongs_to :assessable, polymorphic: true, touch: true
  belongs_to :storage_medium

  delegate :name, to: :storage_medium, prefix: true, allow_nil: true

  validates_inclusion_of :assessable_type, in: %w(Collection FileGroup Repository)
  validates_presence_of :name

  expose_class_config :assessment_types, :risk_levels

  validates_inclusion_of :assessment_type, in: :assessment_types
  validates_inclusion_of :preservation_risk_level, in: :risk_levels

  standard_auto_html(:naming_conventions, :directory_structure, :notes, :preservation_risks)

end
