require 'spec_helper'
require 'avm/image'

describe AVM::Image do
  let(:image) { self.class.describes.new }

  subject { image }

  describe '#initialize' do
    it { should be_a_kind_of(AVM::Image) }

    its(:creator) { should be_a_kind_of(AVM::Creator) }
  end

  describe '#to_xml' do
    let(:xml) { image.to_xml }

    context 'nothing in it' do
      subject { xml.at_xpath('//rdf:RDF').should_not be_nil }
      subject { xml.search('//rdf:RDF/rdf:Description').should be_empty }
    end
  end
end

