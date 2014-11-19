require 'email_person_associator'
class Assessment < ActiveRecord::Base
  email_person_association(:author)

  belongs_to :assessable, :polymorphic => true, touch: true
  belongs_to :storage_medium, touch: true

  validates_inclusion_of :assessable_type, :in => ['Collection', 'FileGroup', 'Repository']
  validates_presence_of :name

  ASSESSMENT_TYPES = %w(external_files)
  RISK_LEVELS = %w(low medium high urgent)

  validates_inclusion_of :assessment_type, :in => ASSESSMENT_TYPES
  validates_inclusion_of :preservation_risk_level, :in => RISK_LEVELS

  [:naming_conventions, :directory_structure, :notes, :preservation_risks].each do |field|
    auto_html_for field do
      html_escape
      link :target => '_blank'
      simple_format
    end
  end

  def storage_medium_name
    self.storage_medium.try(:name)
  end

end
