require 'singleton'
module Medusa
  class ModsToDublinCoreConverter
    include Singleton

    attr_accessor :xslt

    def initialize
      self.xslt = Nokogiri::XSLT.parse(File.read(self.xslt_file_path))
    end

    def xslt_file_path
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
      self.transform_mods_file(filename).tap do |dc|
        add_pid_to_dc(dc, fedora_object)
        add_label_to_object(dc, fedora_object)
      end
    end

    protected

    #This is a bit complex because of the namespaces, but this is how you handle it.
    def add_pid_to_dc(dc_doc, fedora_object)
      id_node = Nokogiri::XML::Node.new('dc:identifier', dc_doc)
      id_node.add_namespace(nil, dc_doc.namespaces['xmlns:dc'])
      id_node.content = fedora_object.pid
      dc_doc.root.add_child(id_node)
    end

    def add_label_to_object(dc_doc, fedora_object)
      title = dc_doc.at_xpath('//dc:title')
      fedora_object.label = title.text if title
    end

  end
end