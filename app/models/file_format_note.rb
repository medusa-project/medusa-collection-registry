class FileFormatNote < ApplicationRecord
  belongs_to :file_format
  belongs_to :user
end
