class Item < ActiveRecord::Base
  belongs_to :project, touch: true

  validates :barcode, presence: true

end
