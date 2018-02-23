class FileFormat < ApplicationRecord
  has_many :file_formats_file_format_profiles_joins, dependent: :destroy
  has_many :file_format_profiles, -> {order :name}, through: :file_formats_file_format_profiles_joins
  has_many :file_format_notes, -> {order :created_at}, dependent: :destroy
  has_many :file_format_normalization_paths, -> {order :created_at}, dependent: :destroy
  has_many :pronoms, -> {order :created_at}, dependent: :destroy

  has_many :file_formats_logical_extensions_joins, -> {order :position}, dependent: :destroy
  has_many :logical_extensions, through: :file_formats_logical_extensions_joins

  def logical_extensions_string
    logical_extensions.collect {|extension| extension.label}.join(', ')
  end

  def logical_extensions_string=(extensions)
    #return if logical_extensions_string == extensions.strip
    if extensions.strip.blank?
      self.logical_extensions = []
    else
      incoming_extensions = extensions.split(',').collect {|ext| LogicalExtension.ensure_extension(ext)}.uniq
      transaction do
        self.logical_extensions.clear
        self.logical_extensions = incoming_extensions
        incoming_extensions.each.with_index do |incoming_extension, i|
          if join = file_formats_logical_extensions_joins.detect {|join| join.logical_extension == incoming_extension}
            join.position = i
            join.save!
          end
        end
      end
    end
  end
  
end