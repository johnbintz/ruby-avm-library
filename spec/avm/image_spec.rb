require 'spec_helper'
require 'avm/image'

describe AVM::Image do
  let(:image) { self.class.describes.new(options) }
  let(:options) { {} }

  subject { image }

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
  let(:redshift) { 'Redshift' }
  let(:light_years) { 'Light years' }

  def self.with_all_options
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
      :image_quality => image_quality,
      :redshift => redshift,
      :light_years => light_years
    } }
  end

  describe '#initialize' do
    with_all_options

    it { should be_a_kind_of(AVM::Image) }

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
    its(:redshift) { should == redshift }
    its(:light_years) { should == light_years }

    its(:distance) { should == [ light_years, redshift ] }
  end

  describe '#to_xml' do
    let(:xml) { image.to_xml }

    let(:dublin_core) { xml.at_xpath('//rdf:Description[@about="Dublin Core"]') }
    let(:photoshop) { xml.at_xpath('//rdf:Description[@about="Photoshop"]') }
    let(:avm) { xml.at_xpath('//rdf:Description[@about="AVM"]') }
      
    context 'nothing in it' do
      it "should have basic tags" do
        xml.at_xpath('//rdf:RDF').should_not be_nil 
        xml.search('//rdf:RDF/rdf:Description').should_not be_empty 
        avm.at_xpath('./avm:Date').should be_nil
      end
    end

    context 'with basics' do
      with_all_options
      
      it "should have the image info tags" do
        dublin_core.at_xpath('./dc:title/rdf:Alt/rdf:li').text.should == title
        photoshop.at_xpath('./photoshop:Headline').text.should == headline
        dublin_core.at_xpath('./dc:description/rdf:Alt/rdf:li').text.should == description
        
        avm.at_xpath('./avm:Distance.Notes').text.should == distance_notes
        avm.at_xpath('./avm:ReferenceURL').text.should == reference_url
        avm.at_xpath('./avm:Credit').text.should == credit
        avm.at_xpath('./avm:Date').text.should == date
        avm.at_xpath('./avm:ID').text.should == id
      end

      context "distance" do
        context "no distances" do

        end

        context "redshift only" do
          
        end
        
        context "light years only" do
          
        end
        
        context "redshift and light years" do
          
        end
      end
    end
  end
end

