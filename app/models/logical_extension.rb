class LogicalExtension < ApplicationRecord

  has_many :file_formats_logical_extensions_joins, dependent: :destroy
  has_many :file_formats, through: :file_formats_logical_extensions_joins
  has_many :file_format_normalization_paths_input_logical_extensions_joins, dependent: :destroy
  has_many :input_file_format_normalization_paths, through: :file_format_normalization_paths_input_logical_extensions_joins, source: :file_format_normalization_path
  has_many :file_format_normalization_paths_output_logical_extensions_joins, dependent: :destroy
  has_many :output_file_format_normalization_paths, through: :file_format_normalization_paths_output_logical_extensions_joins, source: :file_format_normalization_path

  validates_uniqueness_of :description, scope: :extension
  validates_presence_of :extension

  def label
    StringIO.new.tap do |l|
      l << extension
      l << " (#{description})" if description.present?
    end.string
  end

  #Basically we convert things of the form "ext" or "ext (description)" into extensions, without doing much
  # work for variations of the above - just take the first reasonable part for ext and whatever is inside the
  # first parens for the desc
  def self.ensure_extension(string)
    string.match(/^[\s\.]*(\w+).*?\((.*?)\).*$/) or string.match(/^[\s\.]*(\w+).*$/)
    find_or_create_by(extension: $1, description: $2 || '')
  end
end
