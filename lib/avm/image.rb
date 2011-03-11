require 'avm/creator'
require 'avm/xmp'

module AVM
  class Image
    attr_reader :creator

    def initialize
      @creator = AVM::Creator.new(self)
    end

    def to_xml
      document = AVM::XMP.new

      creator.add_to_document(document)

      document.doc
    end

    def self.from_xml(string)
      document = AVM::XMP.from_string(string)

      image = new
      image.creator.from_xml(self, document)
      image
    end
  end
end

