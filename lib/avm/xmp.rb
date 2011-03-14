require 'nokogiri'

module AVM
  class XMP
    PREFIXES = {
      'dc' => 'Dublin Core',
      'Iptc4xmpCore' => 'IPTC',
      'Photoshop' => 'Photoshop'
    }

    attr_reader :doc

    def initialize(doc = nil)
      @doc = doc || empty_xml_doc
      ensure_namespaces!
      ensure_descriptions_findable!
    end

    def get_refs
      yield Hash[[ :dublin_core, :iptc, :photoshop, :avm ].collect { |key| [ key, send(key) ] }]
    end

    def self.from_string(string)
      new(Nokogiri::XML(string))
    end

    private
      def ensure_namespaces!
        {
          :x => "adobe:ns:meta/",
          :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          :dc => "http://purl.org/dc/elements/1.1/",
          :photoshop => "http://ns.adobe.com/photoshop/1.0/",
          :avm => "http://www.communicatingastronomy.org/avm/1.0/",
          :Iptc4xmpCore => "http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/"
        }.each do |namespace, url|
          doc.root.add_namespace_definition(namespace.to_s, url)
        end
      end

      def ensure_descriptions_findable!
        doc.search('//rdf:Description').each do |description|
          if first_child = description.first_element_child
            if first_child.namespace
              description['about'] = PREFIXES[first_child.namespace.prefix]
            end
          end
        end
      end

      def dublin_core
        at_rdf_description "Dublin Core"
      end

      def iptc
        at_rdf_description "IPTC"
      end

      def avm
        at_rdf_description "AVM"
      end

      def photoshop
        at_rdf_description "Photoshop"
      end

      def at_rdf_description(about)
        @doc.at_xpath(%{//rdf:Description[@about="#{about}"]})
      end

      def empty_xml_doc
        Nokogiri::XML(<<-XML)
<x:xmpmeta xmlns:x="adobe:ns:meta/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:RDF>
    <rdf:Description about="Dublin Core" />
    <rdf:Description about="IPTC" />
    <rdf:Description about="Photoshop" />
    <rdf:Description about="AVM" />
  </rdf:RDF>
</x:xmpmeta>
        XML
      end
  end
end

