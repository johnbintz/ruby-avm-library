require 'avm/creator'

module AVM
  class Image
    attr_reader :creator

    def initialize
      @creator = AVM::Creator.new
    end

    def to_xml
      document = empty_xml_doc

      rdf = document.at_xpath('//rdf:RDF')

      creator.add_to_rdf(rdf)

      document
    end

    private
      def empty_xml_doc
        document = Nokogiri::XML(<<-XML)
<x:xmpmeta xmlns:x="adobe:ns:meta/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"><rdf:RDF></rdf:RDF></x:xmpmeta>
        XML
           
        {
          :dc => "http://purl.org/dc/elements/1.1/",
          :photoshop => "http://ns.adobe.com/photoshop/1.0/",
          :avm => "http://www.communicatingastronomy.org/avm/1.0/",
          :Iptc4xmlCore => "http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/"
        }.each do |namespace, url|
          document.root.add_namespace_definition(namespace.to_s, url)
        end

        document
      end
  end
end

