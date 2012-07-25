class Assessment < ActiveRecord::Base
  attr_accessible :collection_id, :date, :notes, :preservation_risks
  belongs_to :collection
end
