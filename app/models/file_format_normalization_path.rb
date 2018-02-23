class FileFormatNormalizationPath < ApplicationRecord
  belongs_to :file_format
  belongs_to :output_format, class_name: 'FileFormat'
  has_many :file_format_normalization_paths_output_logical_extensions_joins, -> {order(:position)}, dependent: :destroy
  has_many :output_logical_extensions, through: :file_format_normalization_paths_output_logical_extensions_joins, source: :logical_extension
  has_many :file_format_normalization_paths_input_logical_extensions_joins, -> {order(:position)}, dependent: :destroy
  has_many :input_logical_extensions, through: :file_format_normalization_paths_input_logical_extensions_joins, source: :logical_extension

  delegate :name, to: :output_format, prefix: true, allow_nil: true

  def input_logical_extensions_string
    LogicalExtension.stringify_collection(input_logical_extensions)
  end

  def output_logical_extensions_string
    LogicalExtension.stringify_collection(output_logical_extensions)
  end

  def input_logical_extensions_string=(extensions)
    LogicalExtension.generic_set_logical_expressions_string(extensions, input_logical_extensions, file_format_normalization_paths_input_logical_extensions_joins)
  end

  def output_logical_extensions_string=(extensions)
    LogicalExtension.generic_set_logical_expressions_string(extensions, output_logical_extensions, file_format_normalization_paths_output_logical_extensions_joins)
  end

end
