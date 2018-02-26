class FileFormatNormalizationPath < ApplicationRecord
  belongs_to :file_format
  belongs_to :output_format, class_name: 'FileFormat'
  belongs_to :input_logical_extension, class_name: 'LogicalExtension'
  belongs_to :output_logical_extension, class_name: 'LogicalExtension'

  delegate :name, to: :output_format, prefix: true, allow_nil: true

end
