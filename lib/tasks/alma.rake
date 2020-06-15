require 'nokogiri'
require 'alma_api/batch'
require 'alma_api/error_response'

namespace :alma do
  desc 'hello'
  task hello: :environment do
    puts 'hello'
    host = Settings.alma.host
    key = Settings.alma.key
    puts host
    puts key
    @alma = AlmaApi::Batch::ApiCaller.new(host,key)
    barcode = '25279'
    item_records = '/almaws/v1/items'
    options = {:item_barcode => barcode }
    items_xml_response = @alma.get(item_records, options)
    lookup_doc = Nokogiri::XML(items_xml_response.body)
    puts lookup_doc
    puts "\n****** bib_data\n"
    puts lookup_doc.xpath('item/bib_data')
  end
  desc 'howdy'
  task howdy: :environment do
    puts 'howdy'
    host = Settings.alma.host
    key = Settings.alma.key
    puts host
    puts key
    @alma = AlmaApi::Batch::ApiCaller.new(host,key)
    barcode = '25279'
    item_records = '/almaws/v1/items'
    options = {:item_barcode => barcode, :view => 'label' }
    items_xml_response = @alma.get(item_records, options)
    lookup_doc = Nokogiri::XML(items_xml_response.body)
    #puts lookup_doc
    puts "\n****** imprint\n"
    puts lookup_doc.xpath('item/item_data/imprint').text
  end
end