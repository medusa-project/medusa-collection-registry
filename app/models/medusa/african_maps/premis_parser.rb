require 'nokogiri'

#parses both the collection and items
module Medusa
  module AfricanMaps
    class PremisParser

      attr_accessor :premis_file, :premis_doc

      def initialize(file)
        self.premis_file = File.expand_path(file)
        File.open(file) do |f|
          self.premis_doc = Nokogiri::XML::Document.parse(f.read)
        end
      end

      def medusa_id
        ids = self.xpath('xmlns:objectIdentifier', self.representations)
        local_id = detect_node(ids, 'objectIdentifierType' => 'LOCAL')
        local_id.at_css('objectIdentifierValue').text
      end

      def related_id(relationship_type, relationship_subtype, identifier_type, root = self.representations)
        relationship = detect_node(self.xpath('xmlns:relationship', root), 'relationshipType' => relationship_type,
                                   'relationshipSubType' => relationship_subtype)
        related_object = detect_node(relationship.xpath('xmlns:relatedObjectIdentification'),
                                     'relatedObjectIdentifierType' => identifier_type)
        related_object.at_css('relatedObjectIdentifierValue').text
      end

      #execute the xpath with the namespaces from the document
      def xpath(xpath, nodeset = self.premis_doc)
        nodeset.xpath(xpath, self.premis_doc.namespaces)
      end

      #all of the premis object nodes
      def objects
        self.xpath('xmlns:premis/xmlns:object')
      end

      #all of the premis object nodes of type representation
      def representations
        self.xpath('xmlns:premis/xmlns:object[@xsi:type="representation"]')
      end

      #all of the premis object nodes of type file
      def files
        self.xpath('xmlns:premis/xmlns:object[@xsi:type="file"]')
      end

      def file(name)
        detect_node(self.files, 'objectIdentifierType' => 'FILENAME', 'objectIdentifierValue' => name)
      end

      def source_file(derived_file)
        related_id('DERIVATION', 'HAS_SOURCE', 'FILENAME', self.file(derived_file))
      end

      #common pattern - given xml node, select subnode with css and compare to given texct
      def text_at_css?(node, css, text)
        node.at_css(css).text == text
      end

      #common pattern - given nodeset find subnode such that for each
      #css => text entry in the hash node.at_css(css).text = text
      def detect_node(nodeset, css_hash)
        nodeset.detect do |node|
          css_hash.all? do |selector, text|
            text_at_css?(node, selector, text)
          end
        end
      end

      #expand path relative to premis file
      def expand_path(filename)
        File.expand_path(filename, File.dirname(self.premis_file)) if filename
      end

    end
  end
end