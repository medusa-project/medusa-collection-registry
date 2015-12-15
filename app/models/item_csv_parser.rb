#take a CSV source and return an array of hashes suitable to become Item objects
require 'csv'
class ItemCsvParser < Object

  attr_accessor :csv, :column_mapping, :headers, :data

  def initialize(csv_data)
    self.csv = csv_data
    self.headers = csv_data.first
    self.data = csv_data.drop(1)
    make_column_mapping
  end

  def self.from_file(file_path)
    #self.new(CSV.parse(File.read(file_path).scrub))
    self.new(CSV.read(file_path, col_sep: "\t", encoding: 'UTF-16:UTF-8'))
  end

  #map canonicalized headers to item fields. If the value needs to be processed then use an array [field, lambda].
  HEADER_MAPPING = {
      '': nil,
      display_call_no: :call_number,
      bib_id: :bib_id,
      title_brief: :title,
      author: :author,
      display_heading: nil,
      publisher_date: nil,
      location_code: nil,
      item_barcode: [:barcode, ->(val) { val.present? ? val : '' }],
      digitization_date: [:reformatting_date, -> (val) {self.parse_date(val)}],
      equipment: :equipment,
      operator: :reformatting_operator,
      foldout_present: [:foldout_present, ->(val) { self.convert_to_boolean(val) }],
      foldout_done: nil,
      special_notes: :notes
  }

  #the column mapping maps positions to the spec for what to do with that data, either directly use it for the given field
  #or process it via a lambda to get the given field value
  def make_column_mapping
    self.column_mapping = Hash.new.tap do |mapping|
      headers.collect { |h| canonicalize_header(h) }.each.with_index do |header, index|
        raise RuntimeError, "Unrecognized canonical header #{header}" unless HEADER_MAPPING.has_key?(header)
        if value = HEADER_MAPPING[header]
          mapping[index] = value
        end
      end
    end
  end

  def canonicalize_header(header)
    (header.present? ? header.gsub(/\(.*\)/, '').strip.gsub(' ', '_').downcase : '').to_sym
  end

  def item_hashes
    self.data.collect do |row|
      row_to_item_hash(row)
    end
  end

  def row_to_item_hash(row)
    Hash.new.tap do |item_hash|
      column_mapping.each do |index, spec|
        field, value = item_field(row[index], spec)
        item_hash[field] = value
      end
    end
  end

  def item_field(input_value, spec)
    if spec.is_a?(Symbol)
      return spec, input_value
    else
      return spec.first, spec.last.call(input_value)
    end
  end

  def add_items_to_project(project)
    project.transaction do
      item_hashes.each do |item_hash|
        project.items.create!(item_hash)
      end
    end
  end
  
  #need to attempt to convert spreadsheet value to a boolean
  def self.convert_to_boolean(value)
    return false if value.blank?
    case value
      when String
        if value.match(/\d+/)
          return !(value.match(/0+/))
        else
          return ['y', 't'].include?(value.first.downcase)
        end
      when Numeric
        return value == 1
      else
        raise RuntimeError, "Unable to convert value #{value} to boolean"
    end
  end

  #TODO - additional fixups on date strings as possible
  #also seen in the wild '31-Jul', 'm/d/y reshot m/d/y'
  def self.parse_date(date_string)
    return '' unless date_string.present?
    Date.strptime(date_string, '%m/%d/%y')
  rescue
    ''
  end

  def row_count
    self.data.count
  end

end