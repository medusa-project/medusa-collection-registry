require 'net_id_person_associator'
class Assessment < ActiveRecord::Base
  net_id_person_association(:author)

  attr_accessible :collection_id, :date, :notes, :preservation_risks
  belongs_to :collection

  [:notes, :preservation_risks].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
    end
  end

end
