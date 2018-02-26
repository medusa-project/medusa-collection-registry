class LogicalExtension < ApplicationRecord

  has_many :file_formats_logical_extensions_joins, dependent: :destroy
  has_many :file_formats, through: :file_formats_logical_extensions_joins
  has_many :input_file_format_normalization_paths, class_name: 'FileFormatNormalizationPath', foreign_key: :input_logical_extension_id
  has_many :output_file_format_normalization_paths, class_name: 'FileFormatNormalizationPath', foreign_key: :output_logical_extension_id

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

  def self.stringify_collection(logical_extensions_collection)
    logical_extensions_collection.collect {|extension| extension.label}.join(', ')
  end

  #This encapsulates the similarities in dealing objects that associate some logical extensions
  # via a join model with position field. 
  def self.generic_set_logical_expressions_string(new_extensions_string, extensions_association, join_association)
    return if new_extensions_string.strip == stringify_collection(extensions_association)
    if new_extensions_string.strip.blank?
      extensions_association.send(:clear)
    else
      incoming_extensions = new_extensions_string.split(',').collect {|ext| LogicalExtension.ensure_extension(ext)}.uniq
      transaction do
        extensions_association.send(:clear)
        extensions_association.send('<<', *incoming_extensions)
        joins = join_association.all
        incoming_extensions.each.with_index do |incoming_extension, i|
          if join = joins.detect {|join| join.logical_extension == incoming_extension}
            join.position = i
            join.save!
          end
        end
      end
    end
  end

end
