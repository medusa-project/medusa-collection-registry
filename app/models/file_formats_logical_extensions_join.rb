class FileFormatsLogicalExtensionsJoin < ApplicationRecord

  belongs_to :file_format
  belongs_to :logical_extension
  
end