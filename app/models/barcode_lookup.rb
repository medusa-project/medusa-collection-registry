# frozen_string_literal: true

require 'nokogiri'
require 'alma_api/batch'
require 'alma_api/error_response'

class BarcodeLookup < Object
  attr_accessor :barcode, :lookup_doc, :call_number
  @@alma_api = AlmaApi::Batch::ApiCaller.new(Settings.alma.host, Settings.alma.key)

  def initialize(barcode)
    self.barcode = barcode
    fetch_and_parse
  end

  def valid?
    lookup_doc.present?
  end

  def item_hashes
    h = Hash.new
    return h unless valid?

    return h if lookup_doc.nil?

    bib_data_node = lookup_doc.xpath('item/bib_data')
    h[:title] = safe_node_xpath_text(bib_data_node, 'title')
    h[:author] = safe_node_xpath_text(bib_data_node, 'author')
    h[:bib_id] = safe_node_xpath_text(bib_data_node, 'mms_id')
    h[:imprint] = safe_node_xpath_text(lookup_doc, 'item/item_data/imprint')
    h[:oclc_number] = oclc_number
    h[:call_number] = safe_node_xpath_text(lookup_doc, 'item/holding_data/call_number')
    h
  end

  protected

  def fetch_and_parse
    item_records = '/almaws/v1/items'
    options = {:item_barcode => barcode, :view => 'label'}
    lookup_doc_response = @@alma_api.get(item_records, options)
    self.lookup_doc = Nokogiri::XML(lookup_doc_response.body)
  rescue OpenURI::HTTPError => error
    Rails.logger.warn error.message
    self.lookup_doc = nil
  end

  def safe_node_xpath_text(node, xpath)
    node.xpath(xpath).text
  rescue StandardError
    ''
  end

  def oclc_number
    network_numbers = []
    bib_data_node.xpath('network_numbers/network_number').each do |network_num_node|
      network_numbers << network_num_node.text
    end
    oclc_numbers = network_numbers.select { |x| x.match(/^\(OCoLC\)/) }
    return '' if oclc_numbers.empty?

    oclc_numbers.first.sub(/^\(OCoLC\)/, '').strip
  rescue StandardError
    ''
  end
end
