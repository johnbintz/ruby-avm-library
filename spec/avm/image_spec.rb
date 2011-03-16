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
  let(:type) { 'Observation' }
  let(:image_quality) { 'Good' }
  let(:redshift) { 'Redshift' }
  let(:light_years) { 'Light years' }

  it "should have spectral notes"

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
      :quality => image_quality,
      :redshift => redshift,
      :light_years => light_years
    } }
  end

  def self.has_most_options
    its(:creator) { should be_a_kind_of(AVM::Creator) }
    its(:title) { should == title }
    its(:headline) { should == headline }
    its(:description) { should == description }
    its(:distance_notes) { should == distance_notes }
    its(:reference_url) { should == reference_url }
    its(:credit) { should == credit }
    its(:date) { should == Time.parse(date) }
    its(:id) { should == id }
    its(:image_type) { should be_a_kind_of eval("AVM::ImageType::#{type}") }
    its(:image_quality) { should be_a_kind_of eval("AVM::ImageQuality::#{image_quality}") }
  end

  describe '#initialize' do
    with_all_options

    it { should be_a_kind_of(AVM::Image) }

    has_most_options

    its(:distance) { should == [ light_years, redshift ] }
  end

  describe '.from_xml' do
    let(:image) { AVM::Image.from_xml(File.read(file_path)) }

    subject { image }

    context "nothing in it" do
      let(:file_path) { 'spec/sample_files/image/nothing.xmp' }

      its(:title) { should be_nil }
      its(:headline) { should be_nil }
      its(:description) { should be_nil }
      its(:distance_notes) { should be_nil }
      its(:reference_url) { should be_nil }
      its(:credit) { should be_nil }
      its(:date) { should be_nil }
      its(:id) { should be_nil }
      its(:image_type) { should be_nil }
      its(:image_quality) { should be_nil }
      its(:redshift) { should be_nil }
      its(:light_years) { should be_nil }
    end
    
    context "image in it" do
      context "distance in light years" do
        let(:file_path) { 'spec/sample_files/image/light_years.xmp' }

        has_most_options

        its(:redshift) { should be_nil }
        its(:light_years) { should == light_years }
      end

      context "distaince in redshift" do
        let(:file_path) { 'spec/sample_files/image/redshift.xmp' }

        has_most_options

        its(:light_years) { should be_nil }
        its(:redshift) { should == redshift }
      end

      context "distance in both" do
        let(:file_path) { 'spec/sample_files/image/both.xmp' }

        has_most_options

        its(:light_years) { should == light_years }
        its(:redshift) { should == redshift }
      end
    end
  end

  describe '#to_xml' do
    let(:xml) { image.to_xml }

    let(:dublin_core) { xml.at_xpath('//rdf:Description[@rdf:about="Dublin Core"]') }
    let(:photoshop) { xml.at_xpath('//rdf:Description[@rdf:about="Photoshop"]') }
    let(:avm) { xml.at_xpath('//rdf:Description[@rdf:about="AVM"]') }
      
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
        avm.at_xpath('./avm:Type').text.should == type
        avm.at_xpath('./avm:Image.ProductQuality').text.should == image_quality
      end

      context "distance" do
        context "no distances" do
          let(:redshift) { nil }
          let(:light_years) { nil }

          specify { avm.at_xpath('./avm:Distance').should be_nil }
        end

        context "redshift only" do
          let(:light_years) { nil }

          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[1]').text.should == '-' }
          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[2]').text.should == redshift }
        end
        
        context "light years only" do
          let(:redshift) { nil }

          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[1]').text.should == light_years }
          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[2]').should be_nil }
        end
        
        context "redshift and light years" do
          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[1]').text.should == light_years }
          specify { avm.at_xpath('./avm:Distance/rdf:Seq/rdf:li[2]').text.should == redshift }
        end
      end
    end
  end
end

