require 'singleton'
module Medusa
  class ModsToDublinCoreConverter
    include Singleton

    attr_accessor :xslt

    def initialize
      self.xslt = Nokogiri::XSLT.parse(File.read(self.dc_file_path))
    end

    def dc_file_path
      File.join(Rails.root, 'vendor', 'assets', 'xslts', 'MODS3-22simpleDC.xsl')
    end

    def transform_mods_file(filename)
      self.transform_mods_xml(File.read(filename))
    end

    def transform_mods_xml(xml)
      self.xslt.transform(Nokogiri::XML::Document.parse(xml))
    end

    #take the mods file, use an xslt to convert to dc, add the object pid as a dc:identifier to the
    #dc, and if there is a dc:title then use it as the label of the object
    def dc_from_mods_file_and_object(filename, fedora_object)
      dc = self.transform_mods_file(filename)
      #now we need to add a dc:identifier with the pid of the object - this is a bit complex because of the namespaces
      id_node = Nokogiri::XML::Node.new('dc:identifier', dc)
      id_node.add_namespace(nil, dc.namespaces['xmlns:dc'])
      id_node.content = fedora_object.pid
      dc.root.add_child(id_node)
      title = dc.at_xpath('//dc:title')
      fedora_object.label = title.text if title
      dc
    end

  end
end