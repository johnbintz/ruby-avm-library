require 'spec_helper'
require 'avm/image'
require 'avm/creator'

describe AVM::Creator do
  let(:image) { AVM::Image.new }
  let(:creator) { image.creator }

  let(:name) { 'Space Telescope Science Institute' }
  let(:url) { 'http://www.stsci.edu/' }
  let(:rights) { 'Public Domain' }

  subject { creator }

  def self.can_read_properties
    its(:name) { should == name }
    its(:url) { should == url }
    its(:rights) { should == rights }
  end

  describe '#merge!' do
    before { creator.merge!(:name => name, :url => url, :rights => rights) }

    can_read_properties
  end

  describe 'setters' do
    before {
      creator.name = name
      creator.url = url
      creator.rights = rights
    }

    can_read_properties
  end

  describe 'primary contact passthrough' do
    context 'no contacts' do
      its(:address) { should be_nil }
    end

    context 'one contact, must be primary' do
      let(:first_contact) { AVM::Contact.new(
        :name => 'zz bill', 
        :address => first_contact_address,
        :city => first_contact_address,
        :state => first_contact_address,
        :postal_code => first_contact_address,
        :country => first_contact_address
      ) }
      let(:first_contact_address) { 'first contact' }

      before { creator.contacts << first_contact }

      fields = [ :address, :city, :state, :province, :postal_code, :zip, :country ]
      fields.each { |field| its(field) { should == first_contact_address } }
      
      context 'two contacts' do
        let(:second_contact) { AVM::Contact.new(
          :name => 'aa bill',
          :address => second_contact_address,
          :city => second_contact_address,
          :state => second_contact_address,
          :postal_code => second_contact_address,
          :country => second_contact_address
        ) }
        let(:second_contact_address) { 'second contact' }

        before { creator.contacts << second_contact }

        context 'no primary, first alphabetical is primary' do
          fields.each { |field| its(field) { should == second_contact_address } }
        end

        context 'one is primary, use it' do
          before { first_contact.primary = true }

          fields.each { |field| its(field) { should == first_contact_address } }
        end
      end
    end
  end

  describe '#create_contact' do
    let(:first_name) { 'John' }
    let(:first_contact) { creator.create_contact(:name => first_name) }

    subject { creator.primary_contact }
    before { first_contact }

    its(:name) { should == first_name }
  end

  describe 'contact name node' do
    let(:first_name) { 'John' }
    let(:second_name) { 'Zohn' }

    let(:first_contact) { creator.create_contact(first_contact_options) }
    let(:second_contact) { creator.create_contact(second_contact_options) }

    let(:first_contact_options) { { :name => first_name } }
    let(:second_contact_options) { { :name => second_name } }

    subject { image.to_xml.search('//dc:creator/rdf:Seq/rdf:li').collect { |node| node.text } }

    context 'no contacts' do
      it { should == [] }
    end

    context 'one contact' do
      before { first_contact }

      it { should == [ first_name ] }
    end

    context 'second contact' do
      before { second_contact ; first_contact }

      it { should == [ first_name, second_name ] }
    end

    describe 'everything else uses primary' do
      let(:fields) { [ :address, :city, :state, :zip, :country ] }

      def other_fields(what)
        Hash[fields.zip(Array.new(fields.length, what))]
      end

      let(:first_contact_options) { { :name => first_name }.merge(other_fields('one')) }
      let(:second_contact_options) { { :name => second_name }.merge(other_fields('two')) }

      before { second_contact ; first_contact }

      specify {
        %w{CiAdrExtadr CiAdrCity CiAdrRegion CiAdrPcode CiAdrCtry}.each do |element_name|
          image.to_xml.at_xpath("//Iptc4xmpCore:#{element_name}").text.should == 'one'
        end
      }
    end

    describe 'contact emails, telephones' do
      let(:first_email) { 'bintz@stsci.edu' }
      let(:second_email) { 'bintz-2@stsci.edu' }

      let(:first_phone) { '123-456-7890' }
      let(:second_phone) { '234-567-8901' }

      let(:first_contact_options) { { :name => first_name, :email => first_email, :telephone => first_phone } }
      let(:second_contact_options) { { :name => second_name, :email => second_email, :telephone => second_phone } }

      let(:contact_info) { image.to_xml.search('//Iptc4xmpCore:CreatorContactInfo') }

      let(:telephone_text) { contact_info.at_xpath('./Iptc4xmpCore:CiTelWork').text }
      let(:email_text) { contact_info.at_xpath('./Iptc4xmpCore:CiEmailWork').text }

      context 'no contacts' do
        specify { expect { telephone_text }.to raise_error }
        specify { expect { email_text }.to raise_error }
      end

      context 'one contact' do
        before { first_contact }

        specify { telephone_text.should == first_phone }
        specify { email_text.should == first_email }
      end

      context 'two contacts' do
        before { first_contact ; second_contact }

        specify { telephone_text.should == [ first_phone, second_phone ] * ',' }
        specify { email_text.should == [ first_email, second_email ] * ',' }
      end
    end
  end
end
