class FileFormatNormalizationPath < ActiveRecord::Base
  belongs_to :file_format
  belongs_to :output_format, class_name: 'FileFormat'
  delegate :name, to: :output_format, prefix: true, allow_nil: true
end
