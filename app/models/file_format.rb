class FileFormat < ApplicationRecord
  has_many :file_formats_file_format_profiles_joins, dependent: :destroy
  has_many :file_format_profiles, -> {order :name}, through: :file_formats_file_format_profiles_joins
  has_many :file_format_notes, -> {order :created_at}, dependent: :destroy
  has_many :file_format_normalization_paths, -> {order :created_at}, dependent: :destroy
  has_many :pronoms, -> {order :created_at}, dependent: :destroy

  has_many :file_formats_logical_extensions_joins, dependent: :destroy
  has_many :logical_extensions, -> {order 'extension asc, description asc'}, through: :file_formats_logical_extensions_joins

  def logical_extensions_string
    logical_extensions.collect {|extension| extension.label}.join(', ')
  end

  def logical_extensions_string=(extensions)
    if extensions.strip.blank?
      self.logical_extensions = []
    else
      incoming_extensions = extensions.split(',').collect {|ext| LogicalExtension.ensure_extension(ext)}.uniq
      transaction do
        self.logical_extensions = incoming_extensions
      end
    end
  end
  
end