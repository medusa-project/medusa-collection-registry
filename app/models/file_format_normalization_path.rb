class FileFormatNormalizationPath < ApplicationRecord
  belongs_to :file_format
  belongs_to :output_format, class_name: 'FileFormat'
  has_many :file_format_normalization_paths_output_logical_extensions_joins, dependent: :destroy
  has_many :output_logical_extensions, through: :file_format_normalization_paths_output_logical_extensions_joins, source: :logical_extension
  has_many :file_format_normalization_paths_input_logical_extensions_joins, dependent: :destroy
  has_many :input_logical_extensions, through: :file_format_normalization_paths_input_logical_extensions_joins, source: :logical_extension

  delegate :name, to: :output_format, prefix: true, allow_nil: true
end
