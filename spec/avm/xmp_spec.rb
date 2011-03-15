require 'spec_helper'
require 'avm/xmp'

describe AVM::XMP do
  let(:xmp) { self.class.describes.new }

  subject { xmp }

  describe '#get_refs' do
    before {
      xmp.get_refs do |refs|
        refs[:dublin_core] << "<rdf:addedToDublinCore />"
        refs[:iptc] << "<rdf:addedToIPTC />"
        refs[:photoshop] << '<rdf:addedToPhotoshop />'
        refs[:avm] << '<rdf:addedToAVM />'
      end
    }

    it "should have gotten the refs correctly" do
      xmp.doc.at_xpath('//rdf:Description[@rdf:about="Dublin Core"]//rdf:addedToDublinCore').should_not be_nil
      xmp.doc.at_xpath('//rdf:Description[@rdf:about="IPTC"]//rdf:addedToIPTC').should_not be_nil
      xmp.doc.at_xpath('//rdf:Description[@rdf:about="Photoshop"]//rdf:addedToPhotoshop').should_not be_nil
      xmp.doc.at_xpath('//rdf:Description[@rdf:about="AVM"]//rdf:addedToAVM').should_not be_nil
    end
  end

  describe '.from_string' do
    let(:xmp) { self.class.describes.from_string(string) }
    let(:string) { '<xml xmlns:rdf="cats"><rdf:RDF><node /></rdf:RDF></xml>' }

    specify { xmp.doc.at_xpath('//node').should_not be_nil }
  end

  describe '#ensure_descriptions_findable!' do
    let(:document) { <<-XML }
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    #{content}
  </rdf:RDF>
</x:xmpmeta>
    XML

    let(:xmp) { self.class.describes.new(Nokogiri::XML(document)) }

    context 'no nodes within' do
      let(:content) { '' }

      [ 'Dublin Core', 'IPTC', 'Photoshop', 'AVM' ].each do |which|
        specify { xmp.doc.at_xpath(%{//rdf:Description[@rdf:about="#{which}"]}).children.should be_empty }
      end
    end

    context 'has identifying nodes within' do
      let(:content) { <<-XML }
<rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:creator />
</rdf:Description>
<rdf:Description rdf:about="" xmlns:Iptc4xmpCore="http://itpc.org/stf/Iptc4xmpCore/1.0/xmlns/">
  <Iptc4xmpCore:CreatorContactInfo rdf:parseType="Resource" />
</rdf:Description>
<rdf:Description rdf:about="" xmlns:Photoshop="http://ns.adobe.com/photoshop/1.0/">
  <photoshop:Something />
</rdf:Description>
<rdf:Description rdf:about="" xmlns:avm="http://www.communicatingastronomy.org/avm/1.0/">
  <avm:Something />
</rdf:Description>
      XML

      [ 'Dublin Core', 'IPTC', 'Photoshop', 'AVM' ].each do |which|
        specify { xmp.doc.at_xpath(%{//rdf:Description[@rdf:about="#{which}"]}).should_not be_nil }
      end
    end
  end
end
