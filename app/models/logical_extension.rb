class LogicalExtension < ApplicationRecord

  has_many :file_formats_logical_extensions_joins, dependent: :destroy
  has_many :file_formats, through: :file_formats_logical_extensions_joins

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
