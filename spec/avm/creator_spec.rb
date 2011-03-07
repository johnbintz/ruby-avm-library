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
      let(:first_contact) { AVM::Contact.new(:name => 'zz bill', :address => first_contact_address) }
      let(:first_contact_address) { 'first contact' }

      before { creator.contacts << first_contact }

      its(:address) { should == first_contact_address }
      
      context 'two contacts' do
        let(:second_contact) { AVM::Contact.new(:name => 'aa bill', :address => second_contact_address) }
        let(:second_contact_address) { 'second contact' }

        before { creator.contacts << second_contact }

        context 'no primary, first alphabetical is primary' do
          its(:address) { should == second_contact_address }
        end

        context 'one is primary, use it' do
          before { first_contact.primary = true }

          its(:address) { should == first_contact_address }
        end
      end
    end
  end
end
