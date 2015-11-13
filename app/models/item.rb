class Item < ActiveRecord::Base
  belongs_to :project, touch: true
  delegate :title, to: :project, prefix: true

  validates :barcode, presence: true

  auto_strip_attributes :barcode

  searchable (include: :project) do
    text :barcode
    string :barcode, stored: true
    string :title
    string :project_title
  end

end
