class FileFormatsFileFormatProfilesJoin < ApplicationRecord

  belongs_to :file_format
  belongs_to :file_format_profile

end