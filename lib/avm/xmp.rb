require 'nokogiri'
require 'avm/node'

module AVM
  class XMP
    PREFIXES = {
      'dc' => 'Dublin Core',
      'Iptc4xmpCore' => 'IPTC',
      'photoshop' => 'Photoshop',
      'avm' => 'AVM'
    }

    REQUIRED_NAMESPACES = {
      :x => "adobe:ns:meta/",
      :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      :dc => "http://purl.org/dc/elements/1.1/",
      :photoshop => "http://ns.adobe.com/photoshop/1.0/",
      :avm => "http://www.communicatingastronomy.org/avm/1.0/",
      :Iptc4xmpCore => "http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/"
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

    def ensure_xmlns(string)
      string.gsub(%r{([</@])(\w+):}) { |all, matches| $1 + (prefix_map[$2] || $2) + ':' }
    end

    alias :% :ensure_xmlns

    def ensure_xpath(path)
      [ ensure_xmlns(path), namespaces ]
    end

    def search(path, node = doc)
      node.search(*ensure_xpath(path))
    end

    def at_xpath(path, node = doc)
      node.at_xpath(*ensure_xpath(path))
    end

    def namespaces
      @namespaces ||= doc.document.collect_namespaces
    end

    private
      def prefix_map
        @prefix_map ||= Hash[doc.document.collect_namespaces.collect { |prefix, namespace|
          prefix = prefix.gsub('xmlns:', '')
          result = nil

          REQUIRED_NAMESPACES.each do |original_prefix, target_namespace|
            result = [ original_prefix.to_s, prefix ] if namespace == target_namespace
          end
          result
        }.compact]
      end

      def ensure_namespaces!
        existing = doc.document.collect_namespaces

        REQUIRED_NAMESPACES.each do |namespace, url|
          doc.root.add_namespace_definition(namespace.to_s, url) if !existing.values.include?(url)
        end
      end

      def ensure_descriptions_findable!
        added = []

        search('//rdf:Description').each do |description|
          if first_child = description.first_element_child
            if first_child.namespace
              prefix = first_child.namespace.prefix

              if prefix_description = PREFIXES[prefix_map.index(prefix)]
                description[self % 'rdf:about'] = prefix_description
                added << prefix
              end
            end
          end
        end

        if !at_xpath('//rdf:RDF')
          doc.first_element_child.add_child(self % '<rdf:RDF />')
        end


        PREFIXES.each do |prefix, about|
          if !added.include?(prefix)
            at_xpath('//rdf:RDF').add_child(self % %{<rdf:Description rdf:about="#{about}" />})
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
        AVM::Node.new(self, at_xpath(%{//rdf:Description[@rdf:about="#{about}"]}))
      end

      def empty_xml_doc
        Nokogiri::XML(<<-XML)
<x:xmpmeta xmlns:x="adobe:ns:meta/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:RDF>
    <rdf:Description rdf:about="Dublin Core" />
    <rdf:Description rdf:about="IPTC" />
    <rdf:Description rdf:about="Photoshop" />
    <rdf:Description rdf:about="AVM" />
  </rdf:RDF>
</x:xmpmeta>
        XML
      end
  end
end

