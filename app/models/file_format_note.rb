class FileFormatNote < ApplicationRecord
  include MedusaAutoHtml

  belongs_to :file_format
  belongs_to :user
  standard_auto_html(:note)

end
