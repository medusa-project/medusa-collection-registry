require 'net_id_person_associator'
class Assessment < ActiveRecord::Base
  net_id_person_association(:author)

  attr_accessible :assessable_id, :date, :notes, :preservation_risks, :assessable_type
  belongs_to :assessable, :polymorphic => true

  [:notes, :preservation_risks].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
      simple_format
    end
  end

end
