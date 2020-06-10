# frozen_string_literal: true

require 'nokogiri'
require 'alma_api/batch'
require 'alma_api/error_response'

class BarcodeLookup < Object
  attr_accessor :barcode, :lookup_doc, :active_item_barcode, :call_number
  @@alma_api = AlmaApi::Batch::ApiCaller.new(ENV['ALMA_HOST'], ENV['ALMA_API_KEY'])
  def initialize(barcode)
    self.barcode = barcode
    fetch_and_parse
  end

  def valid?
    lookup_doc.present? && active_item_barcode.present?
  end

  def item_hashes
    h = []
    return h unless valid?
    lookup_doc.xpath('item/bib_data').each do |bib_data_node|
      h[:title] = begin
                    bib_data_node.xpath('title').text
                  rescue StandardError
                    ''
                  end
      h[:author] = begin
                     bib_data_node.xpath('author').text
                   rescue StandardError
                     ''
                   end
      h[:bib_id] = begin
                     bib_data_node.xpath('mms_id').text
                   rescue StandardError
                     ''
                   end
      h[:imprint] = begin
                      'placeholder imprint'
                    rescue StandardError
                      ''
                    end
      h[:oclc_number] = extract_oclc_number(bib_mfhd)
      h[:call_number] = call_number

      # TitleBrief,
      puts "Title: #{bib_data_node.xpath('title').text}"

      # Author,
      puts "Author: #{bib_data_node.xpath('author').text}"

      # BibId,
      puts "mms_id (Alma bib_id): #{bib_data_node.xpath('mms_id').text}"

      # not sure what imprint is here, so will look up later...
      # probably 260 field in marc, which would be found by using
      # place_of_publication, date_of_publication, and publisher_const

      puts 'Network numbers:'
      bib_data_node.xpath('network_numbers/network_number').each do |network_num_node|
        puts ' ' * 2 + network_num_node.text
      end

    end

    puts 'Call Numbers:'
    lookup_doc.xpath('/item/holding_data/call_number').each do |call_number_node|
      puts ' ' * 2 + call_number_node.text
    end
  end

  # def item_hashes
  #   if self.valid?
  #     self.bib_mfhds.collect do |bib_mfhd|
  #       Hash.new.tap do |h|
  #         h[:title] = bib_mfhd.at_css('TitleBrief').text.sub(/\s*\/\s*$/, '').strip rescue ''
  #         h[:author] = bib_mfhd.at_css('Author').text.strip rescue ''
  #         h[:bib_id] = bib_mfhd.at_css('BibId').text.strip rescue ''
  #         h[:imprint] = bib_mfhd.at_css('Imprint').text.strip rescue ''
  #         h[:oclc_number] = extract_oclc_number(bib_mfhd)
  #         h[:call_number] = call_number
  #       end
  #     end
  #   else
  #     Array.new
  #   end
  # end

  protected

  def fetch_and_parse
    item_records = '/almaws/v1/items'
    options = { 'item_barcode' => barcode }
    lookup_doc_response = @api.get(item_records, options)
    self.lookup_doc = Nokogiri::XML(lookup_doc_response.body)
    set_active_item_barcode
  rescue OpenURI::HTTPError
    self.lookup_doc = nil
  end

  def set_active_item_barcode
    self.active_item_barcode = lookup_doc.css('ItemBarcode').detect do |item_barcode|
      item_barcode.at_css('BarcodeStatus').text == 'Active'
    end
  end

  def call_number
    arr = Array.new
    self.lookup_doc.xpath('/item/holding_data/call_number').each do |call_number_node|
      arr << call_number_node.text
    end
    arr.join(", ")
  rescue StandardError
    ''
  end

  def extract_oclc_number(bib_mfhd)
    node = bib_mfhd.css('NetworkNumber').detect { |x| x.text.match(/^\(OCoLC\)/) }
    node.text.sub(/^\(OCoLC\)/, '').strip if node
  end
end
