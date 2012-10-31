require 'builder/xmlmarkup'

module ModsHelper
  def with_mods_boilerplate
    xml = ::Builder::XmlMarkup.new
    xml.instruct!
    xml.mods(:version => '3.4', 'xsi:schemaLocation' => 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd',
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", :xmlns => "http://www.loc.gov/mods/v3") do
      yield xml
    end
    xml.target!
  end
end