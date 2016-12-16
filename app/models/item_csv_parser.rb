#take a CSV source and return an array of hashes suitable to become Item objects
require 'csv'
class ItemCsvParser < Object

  attr_accessor :csv, :column_mapping, :headers, :data

  def initialize(csv_data)
    self.csv = csv_data
    self.headers = csv_data.first
    self.data = csv_data.drop(1).select {|row| row.detect {|field| field.present?}}
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
      bibid: :bib_id,
      title_brief: :title,
      display_heading: nil,
      publisher_date: nil,
      location_code: nil,
      item_barcode: [:barcode, ->(val) { val.present? ? val : '' }],
      item_number: :item_number,
      digitization_date: [:reformatting_date, -> (val) { self.parse_date(val) }],
      operator: :reformatting_operator,
      special_notes: :notes,
      #from new spreadsheet
      barcode: [:barcode, ->(val) { val.present? ? val : '' }],
      local_title: :local_title,
      batch: :batch,
      file_count: :file_count,
      status: :status,
      #see date format in sample
      reformatting_date: [:reformatting_date, -> (val) { self.parse_date(val) }],
      reformatting_operator: :reformatting_operator,
      equipment: :equipment,
      unique_identifier: :unique_identifier,
      call_number: :call_number,
      title: :title,
      author: :author,
      imprint: :imprint,
      'oclc#': :oclc_number,
      oclc_number: :oclc_number,
      record_series_id: :record_series_id,
      record_series: :record_series_id,
      archival_management_system_url: :archival_management_system_url,
      series: :series,
      'sub-series': :sub_series,
      box: :box,
      folder: :folder,
      item_title: :item_title,
      source_media: :source_media,
      creator: :creator,
      date: :date,
      notes: :notes,
      local_description: :local_description,
      rights_information: :rights_information,
      foldouts_present: [:foldout_present, ->(val) { self.convert_to_boolean(val) }],
      foldout_present: [:foldout_present, ->(val) { self.convert_to_boolean(val) }],
      foldout_done: [:foldout_done, ->(val) { self.convert_to_boolean(val) }],
      item_done: [:item_done, ->(val) { self.convert_to_boolean(val) }],
      ingested: [:ingested, ->(val) {self.convert_to_boolean(val)}]
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
      items = item_hashes.collect do |item_hash|
        project.items.create!(item_hash)
      end
      Sunspot.index! items
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
          return %w(y t).include?(value.first.downcase)
        end
      when Numeric
        return value == 1
      else
        raise RuntimeError, "Unable to convert value #{value} to boolean"
    end
  end

  #Here's the idea: find things that might be mm/dd/yy, yyyy/mm/dd, yyyymmdd. Find as many as possible in each string.
  #Parse them all. Reject any that are in the future. Take the most recent one. Otherwise make the date blank.
  #The DATE_SPECS are a hash from regexps to look for in the string to the format strings used in Date.strptime
  DATE_SPECS = {
      /\d{1,2}\/\d{1,2}\/\d{2}/ => '%m/%d/%y',
      /\d{4}\/\d{1,2}\/\d{1,2}/ => '%Y/%m/%d',
      /\d{8}/ => '%Y%m%d',
      /\d{4}-\d{2}-\d{2}/ => '%Y-%m-%d'
  }
  def self.parse_date(date_string)
    return '' unless date_string.present?
    potential_dates = Set.new
    DATE_SPECS.each do |regexp, format_string|'%Y-%m-%d'
      date_string.scan(regexp).each do |match|
        potential_dates << (Date.strptime(match, format_string) rescue nil)
      end
    end
    potential_dates.delete(nil).reject { |date| date > Date.today }.max || ''
  rescue
    ''
  end

  def row_count
    self.data.count
  end

end
