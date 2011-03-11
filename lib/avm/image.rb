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

      document.doc
    end

    def id
      @options[:id]
    end
    
    def image_type
      @options[:type]
    end

    def date
      Time.parse(@options[:date])
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
  end
end

