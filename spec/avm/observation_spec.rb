require 'spec_helper'
require 'avm/image'
require 'avm/observation'

describe AVM::Observation do
  let(:image) { AVM::Image.new }
  let(:observation) { image.create_observation(options) }

  subject { observation }

  let(:facility) { 'HST' }
  let(:instrument) { 'ACS' }
  let(:color_assignment) { 'Blue' }
  let(:band) { 'em.opt' }
  let(:bandpass) { 'B' }
  let(:wavelength) { 2.5 }
  let(:start_time) { '2010-01-01' }
  let(:start_time_string) { '2010-01-01T00:00' }
  let(:integration_time) { '300' }
  let(:dataset_id) { '12345' }

  let(:options) { {
    :facility => facility,
    :instrument => instrument,
    :color_assignment => color_assignment,
    :band => band,
    :bandpass => bandpass,
    :wavelength => wavelength,
    :start_time => start_time,
    :integration_time => integration_time,
    :dataset_id => dataset_id,
  } }

  let(:second_facility) { 'Chandra' }
  let(:second_instrument) { 'X-Ray' }
  let(:second_color_assignment) { 'Green' }
  let(:second_band) { 'em.x-ray' }
  let(:second_bandpass) { 'C' }
  let(:second_wavelength) { nil }
  let(:second_start_time) { '2010-01-02' }
  let(:second_start_time_string) { '2010-01-02T00:00' }
  let(:second_integration_time) { '400' }
  let(:second_dataset_id) { '23456' }

  let(:second_options) { {
    :facility => second_facility,
    :instrument => second_instrument,
    :color_assignment => second_color_assignment,
    :band => second_band,
    :bandpass => second_bandpass,
    :wavelength => second_wavelength,
    :start_time => second_start_time,
    :integration_time => second_integration_time,
    :dataset_id => second_dataset_id,
  } }

  def self.check_defaults
    its(:facility) { should == facility }
    its(:instrument) { should == instrument }
    its(:color_assignment) { should == color_assignment }
    its(:band) { should == band }
    its(:bandpass) { should == bandpass }
    its(:wavelength) { should == wavelength }
    its(:start_time) { should == Time.parse(start_time) }
    its(:integration_time) { should == integration_time }
    its(:dataset_id) { should == dataset_id }

    its(:to_h) { should == {
      :facility => facility,
      :instrument => instrument,
      :color_assignment => color_assignment,
      :band => band,
      :bandpass => bandpass,
      :wavelength => wavelength,
      :start_time => Time.parse(start_time),
      :integration_time => integration_time,
      :dataset_id => dataset_id
    } }
  end

  context 'defaults' do
    check_defaults
  end

  describe '.from_xml' do
    let(:image) { AVM::Image.from_xml(File.read(file_path)) }
    let(:observations) { image.observations }

    subject { observations }

    context 'no observations' do
      let(:file_path) { 'spec/sample_files/observation/none.xmp' }

      it { should == [] }
    end

    context 'one observation' do
      let(:file_path) { 'spec/sample_files/observation/one.xmp' }

      its(:length) { should == 1 }

      context 'first observation' do
        subject { observations.first }

        check_defaults
      end
    end

    context 'two observations' do
      let(:file_path) { 'spec/sample_files/observation/two.xmp' }

      its(:length) { should == 2 }

      context 'first observation' do
        subject { observations.first }

        check_defaults
      end

      context 'second observation' do
        subject { observations.last }

        its(:facility) { should == second_facility }
        its(:instrument) { should == second_instrument }
        its(:color_assignment) { should == second_color_assignment }
        its(:band) { should == second_band }
        its(:bandpass) { should == second_bandpass }
        its(:wavelength) { should == second_wavelength }
        its(:start_time) { should == Time.parse(second_start_time) }
        its(:integration_time) { should == second_integration_time }
        its(:dataset_id) { should == second_dataset_id }
      end
    end
  end

  describe '.add_to_document' do
    let(:xml) { image.to_xml }
    let(:avm) { xml.at_xpath('//rdf:Description[@rdf:about="AVM"]') }

    context 'none' do
      it "should not have any observation information" do
        %w{Facility Instrument Spectral.ColorAssignment Spectral.Band Spectral.Bandpass Spectral.CentralWavelength Temporal.StartTime Temporal.IntegrationTime DatasetID}.each do |name|
          avm.at_xpath("//avm:#{name}").should be_nil
        end
      end
    end

    context 'one' do
      before { observation }

      it "should have the AVM values" do
        {
          'Facility' => facility,
          'Instrument' => instrument,
          'Spectral.ColorAssignment' => color_assignment,
          'Spectral.Band' => band,
          'Spectral.Bandpass' => bandpass,
          'Spectral.CentralWavelength' => wavelength,
          'Temporal.StartTime' => start_time_string,
          'Temporal.IntegrationTime' => integration_time,
          'DatasetID' => dataset_id
        }.each do |name, value|
          avm.at_xpath("//avm:#{name}").text.should == value.to_s
        end
      end
    end

    context 'two' do
      let(:second_observation) { image.create_observation(second_options) }


      before { observation ; second_observation }

      it "should have the AVM values" do
        {
          'Facility' => [ facility, second_facility ].join(','),
          'Instrument' => [ instrument, second_instrument ].join(','),
          'Spectral.ColorAssignment' => [ color_assignment, second_color_assignment ].join(','),
          'Spectral.Band' => [ band, second_band ].join(','),
          'Spectral.Bandpass' => [ bandpass, second_bandpass ].join(','),
          'Spectral.CentralWavelength' => [ wavelength, second_wavelength || '-' ].join(','),
          'Temporal.StartTime' => [ start_time_string, second_start_time_string ].join(','),
          'Temporal.IntegrationTime' => [ integration_time, second_integration_time ].join(','),
          'DatasetID' => [ dataset_id, second_dataset_id ].join(',')
        }.each do |name, value|
          avm.at_xpath("//avm:#{name}").text.should == value.to_s
        end
      end
    end
  end
end
