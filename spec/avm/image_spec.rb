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
  let(:spectral_notes) { 'Spectral Notes' }
  let(:reference_url) { 'Reference URL' }
  let(:credit) { 'Credit' }
  let(:date) { '2010-01-01' }
  let(:id) { 'ID' }
  let(:type) { 'Observation' }
  let(:image_quality) { 'Good' }
  let(:redshift) { 'Redshift' }
  let(:light_years) { 'Light years' }

  let(:coordinate_frame) { 'ICRS' }
  let(:equinox) { '100' }
  let(:reference_value) { [ 100, 50 ] }
  let(:reference_dimension) { [ 200, 150 ] }
  let(:reference_pixel) { [ 25, 15 ] }
  let(:spatial_scale) { [ 40, 35 ] }
  let(:spatial_rotation) { 10.0 }
  let(:coordinate_system_projection) { 'TAN' }
  let(:spatial_quality) { 'Full' }
  let(:spatial_notes) { 'Spatial Notes' }
  let(:fits_header) { 'FITS header' }
  let(:spatial_cd_matrix) { [ 1, 2, 3, 4 ] }

  def self.with_all_options
    let(:options) { { 
      :title => title, 
      :headline => headline, 
      :description => description, 
      :distance_notes => distance_notes, 
      :spectral_notes => spectral_notes, 
      :reference_url => reference_url, 
      :credit => credit, 
      :date => date, 
      :id => id, 
      :type => type, 
      :quality => image_quality,
      :redshift => redshift,
      :light_years => light_years,
      :coordinate_frame => coordinate_frame,
      :equinox => equinox,
      :reference_value => reference_value,
      :reference_dimension => reference_dimension,
      :reference_pixel => reference_pixel,
      :spatial_scale => spatial_scale,
      :spatial_rotation => spatial_rotation,
      :coordinate_system_projection => coordinate_system_projection,
      :spatial_quality => spatial_quality,
      :spatial_notes => spatial_notes,
      :fits_header => fits_header,
      :spatial_cd_matrix => spatial_cd_matrix,
    } }
  end

  let(:avm_image_type) { eval("AVM::ImageType::#{type}") }
  let(:avm_image_quality) { eval("AVM::ImageQuality::#{image_quality}") }
  let(:avm_coordinate_frame) { eval("AVM::CoordinateFrame::#{coordinate_frame}") }
  let(:avm_coordinate_system_projection) { eval("AVM::CoordinateSystemProjection::#{coordinate_system_projection}") }
  let(:avm_spatial_quality) { eval("AVM::SpatialQuality::#{spatial_quality}") }

  def self.has_most_options
    its(:creator) { should be_a_kind_of(AVM::Creator) }
    its(:title) { should == title }
    its(:headline) { should == headline }
    its(:description) { should == description }
    its(:distance_notes) { should == distance_notes }
    its(:spectral_notes) { should == spectral_notes }
    its(:reference_url) { should == reference_url }
    its(:credit) { should == credit }
    its(:date) { should == Time.parse(date) }
    its(:id) { should == id }
    its(:image_type) { should be_a_kind_of avm_image_type }
    its(:image_quality) { should be_a_kind_of avm_image_quality }

    its(:coordinate_frame) { should be_a_kind_of avm_coordinate_frame }
    its(:equinox) { should == equinox }
    its(:reference_value) { should == reference_value }
    its(:reference_dimension) { should == reference_dimension }
    its(:reference_pixel) { should == reference_pixel }
    its(:spatial_scale) { should == spatial_scale }
    its(:spatial_rotation) { should == spatial_rotation }
    its(:coordinate_system_projection) { should be_a_kind_of avm_coordinate_system_projection }
    its(:spatial_quality) { should be_a_kind_of avm_spatial_quality }
    its(:spatial_notes) { should == spatial_notes }
    its(:fits_header) { should == fits_header }
    its(:spatial_cd_matrix) { should == spatial_cd_matrix }
  end

  describe '#initialize' do
    with_all_options

    it { should be_a_kind_of(AVM::Image) }

    has_most_options

    its(:to_h) { should == {
      :title => title,
      :headline => headline,
      :description => description,
      :distance_notes => distance_notes,
      :spectral_notes => spectral_notes,
      :reference_url => reference_url,
      :credit => credit,
      :date => Time.parse(date),
      :id => id,
      :image_type => avm_image_type.new,
      :image_quality => avm_image_quality.new,
      :coordinate_frame => avm_coordinate_frame.new,
      :equinox => equinox,
      :reference_value => reference_value,
      :reference_dimension => reference_dimension,
      :reference_pixel => reference_pixel,
      :spatial_scale => spatial_scale,
      :spatial_rotation => spatial_rotation,
      :coordinate_system_projection => avm_coordinate_system_projection.new,
      :spatial_quality => avm_spatial_quality.new,
      :spatial_notes => spatial_notes,
      :fits_header => fits_header,
      :spatial_cd_matrix => spatial_cd_matrix,
      :distance => [ light_years, redshift ],
      :creator => []
    } }

    its(:distance) { should == [ light_years, redshift ] }
  end

  describe '.from_xml' do
    let(:image) { AVM::Image.from_xml(File.read(file_path)) }

    subject { image }

    context "nothing in it" do
      let(:file_path) { 'spec/sample_files/image/nothing.xmp' }

      [ :title, :headline, :description, :distance_notes,
        :spectral_notes, :reference_url, :credit, :date,
        :id, :image_type, :image_quality, :redshift,
        :light_years, :coordinate_frame, :equinox, :reference_value,
        :reference_dimension, :reference_pixel, :spatial_scale,
        :spatial_rotation, :coordinate_system_projection, :spatial_quality, :spatial_notes,
        :fits_header, :spatial_cd_matrix
      ].each do |field|
        its(field) { should be_nil }
      end
    end

    context "image in it" do
      context 'distance as a single value, assume light years' do
        let(:file_path) { 'spec/sample_files/image/single_value_light_years.xmp' }

        has_most_options

        its(:redshift) { should be_nil }
        its(:light_years) { should == light_years }
      end

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
        photoshop.at_xpath('./photoshop:DateCreated').should_not be_nil
      end
    end

    context 'with basics' do
      with_all_options
      
      def xpath_text(which, xpath)
        which.at_xpath(xpath).text
      end

      def xpath_list(which, xpath)
        which.at_xpath(xpath).search('.//rdf:li').collect(&:text)
      end

      it "should have the image info tags" do
        xpath_text(dublin_core, './dc:title/rdf:Alt/rdf:li').should == title
        xpath_text(photoshop, './photoshop:Headline').should == headline
        xpath_text(dublin_core, './dc:description/rdf:Alt/rdf:li').should == description
                
        xpath_text(avm, './avm:Distance.Notes').should == distance_notes
        xpath_text(avm, './avm:Spectral.Notes').should == spectral_notes
        xpath_text(avm, './avm:ReferenceURL').should == reference_url
        xpath_text(avm, './avm:Credit').should == credit
        xpath_text(photoshop, './photoshop:DateCreated').should == date
        xpath_text(avm, './avm:ID').should == id
        xpath_text(avm, './avm:Type').should == type
        xpath_text(avm, './avm:Image.ProductQuality').should == image_quality
      end

      it "should have the spatial tags" do
        xpath_text(avm, './avm:Spatial.CoordinateFrame').should == coordinate_frame
        xpath_text(avm, './avm:Spatial.Equinox').should == equinox
        xpath_list(avm, './avm:Spatial.ReferenceValue').should == reference_value.collect(&:to_s)
        xpath_list(avm, './avm:Spatial.ReferenceDimension').should == reference_dimension.collect(&:to_s)
        xpath_list(avm, './avm:Spatial.ReferencePixel').should == reference_pixel.collect(&:to_s)
        xpath_list(avm, './avm:Spatial.Scale').should == spatial_scale.collect(&:to_s)
        xpath_text(avm, './avm:Spatial.CoordsystemProjection').should == coordinate_system_projection
        xpath_text(avm, './avm:Spatial.Quality').should == spatial_quality
        xpath_text(avm, './avm:Spatial.Notes').should == spatial_notes
        xpath_text(avm, './avm:Spatial.FITSheader').should == fits_header
        xpath_list(avm, './avm:Spatial.CDMatrix').should == spatial_cd_matrix.collect(&:to_s)
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

