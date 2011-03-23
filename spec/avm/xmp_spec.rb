require 'spec_helper'
require 'avm/xmp'

describe AVM::XMP do
  let(:xmp) { self.class.describes.new }

  subject { xmp }

  describe '#initialize' do
    context 'not a nokogiri document' do
      let(:xmp) { self.class.describes.new("definitely not nokogiri node") }

      it { expect { xmp }.to raise_error(StandardError, /not a Nokogiri node/) }
    end
  end

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

  describe 'xml from string' do
    let(:xmp) { self.class.describes.from_string(string) }
    let(:doc) { xmp.doc }

    describe '.from_string' do
      let(:string) { '<xml xmlns:rdf="cats"><rdf:RDF><node /></rdf:RDF></xml>' }

      specify { xmp.doc.at_xpath('//node').should_not be_nil }
    end

    describe '#ensure_namespaces! and #ensure_xmlns' do
      let(:rdf_namespace) { AVM::XMP::REQUIRED_NAMESPACES[:rdf] }

      def self.all_default_namespaces
        it "should have all the namespaces with the default prefixes" do
          namespaces = doc.document.collect_namespaces

          namespaces_to_test = AVM::XMP::REQUIRED_NAMESPACES.dup
          yield namespaces_to_test if block_given?

          namespaces_to_test.each do |prefix, namespace|
            if namespace
              namespaces["xmlns:#{prefix}"].should == namespace
            end
          end
        end
      end

      before { doc }

      context 'none of the namespaces exist' do
        let(:string) { '<xml><node /></xml>' }

        all_default_namespaces

        specify { xmp.ensure_xmlns('.//rdf:what').should == './/rdf:what' }
      end

      context 'one namespace exists with the same prefix' do
        let(:string) { %{<xml xmlns:rdf="#{rdf_namespace}"><node /></xml>} }

        all_default_namespaces

        specify { xmp.ensure_xmlns('.//rdf:what').should == './/rdf:what' }
      end

      context 'one namespace exists with a different prefix' do
        let(:string) { %{<xml xmlns:r="#{rdf_namespace}"><node /></xml>} }

        all_default_namespaces { |namespaces|
          namespaces.delete(:rdf)
          namespaces[:r] = AVM::XMP::REQUIRED_NAMESPACES[:rdf]
        }

        specify { xmp.ensure_xmlns('.//rdf:what').should == './/r:what' }
      end
    end
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
        specify { xmp.at_xpath(%{//rdf:Description[@rdf:about="#{which}"]}).children.should be_empty }
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
        specify { xmp.at_xpath(%{//rdf:Description[@rdf:about="#{which}"]}).should_not be_nil }
      end
    end

    context 'has a namespace it should know about with a different prefix' do
      let(:content) { <<-XML }
<rdf:Description rdf:about="" xmlns:whatever="http://purl.org/dc/elements/1.1/">
  <whatever:creator />
</rdf:Description>
      XML

      specify { xmp.at_xpath(%{//rdf:Description[@rdf:about="Dublin Core"]}).should_not be_nil }
    end

    context 'has a namespace it knows nothing about' do
      let(:content) { <<-XML }
<rdf:Description rdf:about="" xmlns:whatever="http://example.com">
  <whatever:creator />
</rdf:Description>
      XML

      it { expect { xmp }.to_not raise_error }
    end
  end
end
