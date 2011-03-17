require 'spec_helper'
require 'avm/contact'

describe AVM::Contact do
  let(:contact) { AVM::Contact.new(contact_info) }

  subject { contact }

  let(:contact_info) { {
    :name => name,
    :email => email,
    :telephone => telephone,
    :address => address,
    :city => city,
    :state => state,
    :postal_code => postal_code,
    :country => country
  } }

  let(:name) { 'John Bintz' }
  let(:email) { 'bintz@stsci.edu' }
  let(:telephone) { '800-555-1234' }
  let(:address) { '3700 San Martin Drive' }
  let(:city) { 'Baltimore' }
  let(:state) { 'Maryland' }
  let(:postal_code) { '21218' }
  let(:country) { 'USA' }

  its(:name) { should == name }
  its(:email) { should == email }
  its(:telephone) { should == telephone }
  its(:address) { should == address }
  its(:city) { should == city }
  its(:state) { should == state }
  its(:province) { should == state }
  its(:postal_code) { should == postal_code }
  its(:zip) { should == postal_code }
  its(:country) { should == country }

  its(:to_h) { should == {
    :name => name,
    :email => email,
    :telephone => telephone,
    :address => address,
    :city => city,
    :state => state,
    :postal_code => postal_code,
    :country => country
  } }

  its(:to_creator_list_element) { should == "<rdf:li>John Bintz</rdf:li>" }

  describe 'mappings' do
    AVM::Contact::FIELD_MAP.each do |key, value|
      context "#{key} => #{value}" do
        let(:contact_info) { { key => "test" } }

        its(value) { should == "test" }
      end
    end
  end

  context '#<=>' do
    let(:second_contact) { AVM::Contact.new(second_contact_info) }
    let(:contacts) { [ contact, second_contact ] }

    let(:second_name) { 'Aohn Bintz' }

    let(:second_contact_info) { {
      :name => second_name,
      :email => email,
      :telephone => telephone,
      :address => address,
      :city => city,
      :state => state,
      :postal_code => postal_code,
      :country => country
    } }

    subject { contacts.sort }

    context 'primary not set' do
      it { should == [ second_contact, contact ] }
    end

    context 'primary set' do
      before { contact.primary = true }

      it { should == [ contact, second_contact ] }
    end
  end
end

