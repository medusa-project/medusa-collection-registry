class FileFormat < ApplicationRecord
  has_many :file_formats_file_format_profiles_joins, dependent: :destroy
  has_many :file_format_profiles, -> {order :name}, through: :file_formats_file_format_profiles_joins
  has_many :file_format_notes, -> {order :created_at}, dependent: :destroy
  has_many :file_format_normalization_paths, -> {order :created_at}, dependent: :destroy
  has_many :pronoms, -> {order :created_at}, dependent: :destroy

  has_many :file_formats_logical_extensions_joins, -> {order :position}, dependent: :destroy
  has_many :logical_extensions, through: :file_formats_logical_extensions_joins

  has_many :related_file_format_joins, dependent: :destroy
  #Note this shouldn't destroy the related format when deleting, instead it ensures that the destroy callback
  # on the join fires, which is needed for symmetry
  has_many :related_file_formats, through: :related_file_format_joins, dependent: :destroy

  has_many :attachments, as: :attachable, dependent: :destroy

  def logical_extensions_string
    LogicalExtension.stringify_collection(logical_extensions)
  end

  def logical_extensions_string=(extensions)
    LogicalExtension.generic_set_logical_expressions_string(extensions, logical_extensions, file_formats_logical_extensions_joins)
  end
  
end