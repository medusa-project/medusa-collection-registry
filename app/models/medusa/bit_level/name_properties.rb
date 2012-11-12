module Medusa
  module BitLevel
    class NameProperties < ActiveFedora::NokogiriDatastream
      include OM::XML::Document

      set_terminology do |t|
        t.root(:path => 'fields', :xmlns => 'medusa')
        t.name(:xmlns => 'medusa', :index_as => [:searchable, :sortable])
      end

      def self.xml_template
        Nokogiri::XML::Builder.new do |xml|
          xml.fields('xmlns' => 'medusa')
        end.doc
      end

      def name
        self.term_values(:name).first
      end

      def name=(name)
        self.update_values([:name] => name)
      end
    end
  end
end