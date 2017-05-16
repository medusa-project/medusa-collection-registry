class FileFormatProfilesContentTypesJoin < ApplicationRecord
  belongs_to :file_format_profile
  belongs_to :content_type
end
