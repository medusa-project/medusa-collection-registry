class FileFormatsLogicalExtensionsJoin < ActiveRecord

  belongs_to :file_format
  belongs_to :logical_extension
  
end