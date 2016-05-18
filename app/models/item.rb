class Item < ActiveRecord::Base
  belongs_to :project, touch: true
  delegate :title, to: :project, prefix: true

  before_validation :ensure_barcode
  auto_strip_attributes :barcode, nullify: false

  STATUSES = ['Sent to Conservation', 'Sent to Preservation', 'Sent to IPM', 'Sent for cataloging', 'Send to IA for digitization']
  EQUIPMENT_TYPES = ['BC100', 'RCAM', 'Canon Sheetfed', 'Epson Flatbed']
  validates :status, inclusion: STATUSES, allow_blank: true
  validates :barcode, allow_blank: true, format: /\d{14}/

  searchable include: :project do
    %i(barcode batch).each do |field|
      text field
      string field, stored: true
    end
    %i(some_title bib_id call_number author record_series_id oclc_number imprint local_title local_description
reformatting_operator archival_management_system_url series sub_series box).each do |field|
      text field
      string field
    end
    text :notes
    string :project_title
    integer :project_id
    time :updated_at
    date :reformatting_date
  end

  def ensure_barcode
    self.barcode ||= ''
  end

  def some_title
    title.if_blank(item_title.if_blank(local_title))
  end

end
