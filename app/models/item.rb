class Item < ActiveRecord::Base
  belongs_to :project, touch: true
  delegate :title, to: :project, prefix: true

  before_validation :ensure_barcode
  auto_strip_attributes :barcode, nullify: false

  STATUSES = ['Sent to Conservation', 'Sent to Preservation', 'Sent to IPM', 'Sent for cataloging', 'Send to IA for digitization']

  validates :status, inclusion: STATUSES, allow_blank: true

  searchable include: :project do
    %i(barcode batch).each do |field|
      text field
      string field, stored: true
    end
    %i(some_title bib_id call_number author record_series_id).each do |field|
      text field
      string field
    end
    text :notes
    string :project_title
    integer :project_id
  end

  def ensure_barcode
    self.barcode ||= ''
  end

  def some_title
    title.if_blank(item_title.if_blank(local_title))
  end

end
