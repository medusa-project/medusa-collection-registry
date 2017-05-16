class FileFormatProfilesFileExtensionsJoin < ApplicationRecord
  belongs_to :file_format_profile
  belongs_to :file_extension
end
