require 'avm/creator'
require 'avm/xmp'
require 'avm/image_type'
require 'avm/image_quality'

module AVM
  class Image
    DUBLIN_CORE_FIELDS = [ :title, :description ]
    AVM_SINGLE_FIELDS = [ 'Distance.Notes', 'ReferenceURL', 'Credit', 'Date', 'ID', 'Type', 'Image.ProductQuality' ]

    attr_reader :creator

    def initialize(options = {})
      @creator = AVM::Creator.new(self)
      @options = options
    end

    def to_xml
      document = AVM::XMP.new

      creator.add_to_document(document)

      document.get_refs do |refs|
        DUBLIN_CORE_FIELDS.each do |field|
          refs[:dublin_core].add_child(%{<dc:#{field}>#{alt_li_tag(send(field))}</dc:#{field}>})
        end

        refs[:photoshop].add_child(%{<photoshop:Headline>#{headline}</photoshop:Headline>})

        AVM_SINGLE_FIELDS.zip([distance_notes, reference_url, credit, string_date, id, image_type, image_quality]).each do |tag, value|
          refs[:avm].add_child(%{<avm:#{tag}>#{value.to_s}</avm:#{tag}>}) if value
        end

        distance_nodes = []
        distance_nodes << rdf_li(light_years) if light_years
        if redshift
          distance_nodes << rdf_li('-') if distance_nodes.empty?
          distance_nodes << rdf_li(redshift)
        end

        if !distance_nodes.empty?
          refs[:avm].add_child(%{<avm:Distance><rdf:Seq>#{distance_nodes.join}</rdf:Seq></avm:Distance>})
        end
      end

      document.doc
    end

    def id
      @options[:id]
    end
    
    def image_type
      (AVM::ImageType.const_get(@options[:type].to_sym).new rescue nil)
    end

    def image_quality
      (AVM::ImageQuality.const_get(@options[:quality].to_sym).new rescue nil)
    end

    def date
      (Time.parse(@options[:date]) rescue nil)
    end

    def string_date
      return nil if !date
      date.strftime('%Y-%m-%d')
    end

    def distance
      [ light_years, redshift ]
    end

    def self.from_xml(string)
      document = AVM::XMP.from_string(string)

      options = {}

      document.get_refs do |refs|
        DUBLIN_CORE_FIELDS.each do |field|
          if node = refs[:dublin_core].at_xpath(".//dc:#{field}//rdf:li[1]")
            options[field] = node.text
          end
        end

        AVM_SINGLE_FIELDS.zip([ :distance_notes, :reference_url, :credit, :date, :id, :type, :quality ]).each do |tag, field|
          if node = refs[:avm].at_xpath("./avm:#{tag}")
            options[field] = node.text
          end
        end

        if node = refs[:photoshop].at_xpath('./photoshop:Headline')
          options[:headline] = node.text
        end

        if node = refs[:avm].at_xpath('./avm:Distance')
          list_values = node.search('.//rdf:li').collect { |li| li.text }

          case list_values.length
          when 1
            options[:light_years] = list_values.first
          when 2
            options[:light_years] = (list_values.first == '-') ? nil : list_values.first
            options[:redshift] = list_values.last
          end
        end
      end

      image = new(options)
      image.creator.from_xml(self, document)
      image
    end

    def method_missing(method)
      @options[method]
    end

    private
      def alt_li_tag(text)
        %{<rdf:Alt><rdf:li xml:lang="x-default">#{text}</rdf:li></rdf:Alt>}
      end

      def rdf_li(text)
        %{<rdf:li>#{text}</rdf:li>}
      end
  end
end

