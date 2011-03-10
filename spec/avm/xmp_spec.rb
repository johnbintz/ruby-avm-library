require 'spec_helper'
require 'avm/xmp'

describe AVM::XMP do
  let(:xmp) { self.class.describes.new }

  describe '#add_to_doc' do
    before {
      xmp.add_to_doc do |refs|
        refs[:dublin_core] << "<rdf:addedToDublinCore />"
        refs[:iptc] << "<rdf:addedToIPTC />"
      end
    }

    specify { xmp.doc.at_xpath('//rdf:Description[@about="Dublin Core"]//rdf:addedToDublinCore').should_not be_nil }
    specify { xmp.doc.at_xpath('//rdf:Description[@about="IPTC"]//rdf:addedToIPTC').should_not be_nil }
  end
end
