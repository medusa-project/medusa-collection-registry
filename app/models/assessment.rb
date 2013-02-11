require 'net_id_person_associator'
class Assessment < ActiveRecord::Base
  net_id_person_association(:author)

  attr_accessible :assessable_id, :date, :notes, :preservation_risks, :assessable_type, :name,
                  :preservation_risk_level, :assessment_type
  belongs_to :assessable, :polymorphic => true

  validates_inclusion_of :assessable_type, :in => ['Collection', 'FileGroup']
  validates_presence_of :name

  ASSESSMENT_TYPES = %w(external_files)
  RISK_LEVELS = %w(low medium high urgent)

  validates_inclusion_of :assessment_type, :in => ASSESSMENT_TYPES
  validates_inclusion_of :preservation_risk_level, :in => RISK_LEVELS

  [:notes, :preservation_risks].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
      simple_format
    end
  end

end
