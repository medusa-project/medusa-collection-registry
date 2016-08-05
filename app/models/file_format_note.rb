class FileFormatNote < ActiveRecord::Base
  belongs_to :file_format
  belongs_to :user
end
