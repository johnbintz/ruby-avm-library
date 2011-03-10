require 'nokogiri'

module AVM
  class XMP
    attr_reader :doc

    def initialize
      @doc = empty_xml_doc
    end

    def add_to_doc
      yield Hash[[ :dublin_core, :iptc ].collect { |key| [ key, send(key) ] }]
    end

    private
      def dublin_core
        at_rdf_description "Dublin Core"
      end

      def iptc
        at_rdf_description "IPTC"
      end

      def at_rdf_description(about)
        @doc.at_xpath(%{//rdf:Description[@about="#{about}"]})
      end

      def empty_xml_doc
        document = Nokogiri::XML(<<-XML)
<x:xmpmeta xmlns:x="adobe:ns:meta/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:RDF>
    <rdf:Description about="Dublin Core">

    </rdf:Description>
    <rdf:Description about="IPTC">

    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
        XML
           
        {
          :dc => "http://purl.org/dc/elements/1.1/",
          :photoshop => "http://ns.adobe.com/photoshop/1.0/",
          :avm => "http://www.communicatingastronomy.org/avm/1.0/",
          :Iptc4xmpCore => "http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/"
        }.each do |namespace, url|
          document.root.add_namespace_definition(namespace.to_s, url)
        end

        document
      end
  end
end

