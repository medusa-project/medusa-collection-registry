#This is pretty fragile right now, and may remain so until we have a better idea what fields we want
#and what possible problems there could be in obtaining them from Tom's service.
class BarcodeLookup < Object

  attr_accessor :barcode, :lookup_doc, :active_item_barcode

  def initialize(barcode)
    self.barcode = barcode
    fetch_and_parse
  end

  def fetch_and_parse
    self.lookup_doc = Nokogiri::XML(open("http://s1.library.illinois.edu/barcode/Service/GetDetails/#{self.barcode}"))
    set_active_item_barcode
  end

  def set_active_item_barcode
    self.active_item_barcode = self.lookup_doc.css('ItemBarcode').detect do |item_barcode|
      item_barcode.at_css('BarcodeStatus').text == 'Active'
    end
  end

  def call_number
    self.active_item_barcode.at_css('DisplayCallNo').text
  end

  def bib_mfhds
    self.active_item_barcode.css('BibMfhd')
  end

  def item_hashes
    self.bib_mfhds.collect do |bib_mfhd|
      Hash.new.tap do |h|
        h[:title] = bib_mfhd.at_css('TitleBrief').text.sub(/\s*\/\s*$/, '').strip
        h[:author] = bib_mfhd.at_css('Author').text.strip
        h[:bib_id] = bib_mfhd.at_css('BibId').text.strip
        h[:imprint] = bib_mfhd.at_css('Imprint').text.strip
        h[:oclc_number] = extract_oclc_number(bib_mfhd)
      end
    end
  end

  def extract_oclc_number(bib_mfhd)
    node = bib_mfhd.css('NetworkNumber').detect { |x| x.text.match(/^\(OCoLC\)/) }
    if node
      node.text.sub(/^\(OCoLC\)/, '').strip
    else
      nil
    end

  end

end