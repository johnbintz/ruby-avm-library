require 'spec_helper'
require 'avm/image'

describe AVM::Image do
  let(:image) { self.class.describes.new(options) }
  let(:options) { {} }

  subject { image }

  describe '#initialize' do
    it { should be_a_kind_of(AVM::Image) }

    let(:options) { { 
      :title => title, 
      :headline => headline, 
      :description => description, 
      :distance_notes => distance_notes, 
      :reference_url => reference_url, 
      :credit => credit, 
      :date => date, 
      :id => id, 
      :type => type, 
      :image_quality => image_quality 
    } }

    let(:title) { 'My title' }
    let(:headline) { 'Headline' }
    let(:description) { 'Description' }
    let(:distance_notes) { 'Distance Notes' }
    let(:reference_url) { 'Reference URL' }
    let(:credit) { 'Credit' }
    let(:date) { '2010-01-01' }
    let(:id) { 'ID' }
    let(:type) { 'Obvservation' }
    let(:image_quality) { 'Good' }

    its(:creator) { should be_a_kind_of(AVM::Creator) }
    its(:title) { should == title }
    its(:headline) { should == headline }
    its(:description) { should == description }
    its(:distance_notes) { should == distance_notes }
    its(:reference_url) { should == reference_url }
    its(:credit) { should == credit }
    its(:date) { should == Time.parse(date) }
    its(:id) { should == id }
    its(:image_type) { should == type }
    its(:image_quality) { should == image_quality }
  end

  describe '#to_xml' do
    let(:xml) { image.to_xml }

    context 'nothing in it' do
      subject { xml.at_xpath('//rdf:RDF').should_not be_nil }
      subject { xml.search('//rdf:RDF/rdf:Description').should be_empty }
    end
  end
end

