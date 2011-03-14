require 'avm/creator'
require 'avm/xmp'

module AVM
  class Image
    attr_reader :creator

    def initialize(options = {})
      @creator = AVM::Creator.new(self)
      @options = options
    end

    def to_xml
      document = AVM::XMP.new

      creator.add_to_document(document)

      document.get_refs do |refs|
        [ :title, :description ].each do |field|
          refs[:dublin_core].add_child(%{<dc:#{field}>#{alt_li_tag(send(field))}</dc:#{field}>})
        end

        refs[:photoshop].add_child(%{<photoshop:Headline>#{headline}</photoshop:Headline>})

        {
          'Distance.Notes' => distance_notes,
          'ReferenceURL' => reference_url,
          'Credit' => credit,
          'Date' => string_date,
          'ID' => id,
        }.each do |tag, value|
          refs[:avm].add_child(%{<avm:#{tag}>#{value}</avm:#{tag}>}) if value
        end
      end

      document.doc
    end

    def id
      @options[:id]
    end
    
    def image_type
      @options[:type]
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

      image = new
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
  end
end

