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
  end
end

