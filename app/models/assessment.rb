require 'net_id_person_associator'
class Assessment < ActiveRecord::Base
  net_id_person_association(:author)

  attr_accessible :collection_id, :date, :notes, :preservation_risks
  belongs_to :collection
end
