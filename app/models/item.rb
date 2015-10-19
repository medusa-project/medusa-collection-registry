class Item < ActiveRecord::Base
  belongs_to :project, touch: true

  validates :barcode, presence: true
  validates :tif_completed, :qa_tif, :transferred_to_hathi, :transferred_to_medusa, inclusion: [true, false]
end
