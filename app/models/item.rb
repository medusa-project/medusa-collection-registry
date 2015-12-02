class Item < ActiveRecord::Base
  belongs_to :project, touch: true
  delegate :title, to: :project, prefix: true

  before_validation :ensure_barcode
  auto_strip_attributes :barcode, nullify: false

  STATUSES = ['Sent to Conservation', 'Sent to Preservation', 'Sent to IPM', 'Sent for cataloging', 'Send to IA for digitization']

  validates :status, inclusion: STATUSES, allow_blank: true

  searchable include: :project do
    text :barcode
    string :barcode, stored: true
    string :title
    string :project_title
  end

  def ensure_barcode
    self.barcode ||= ''
  end

end
