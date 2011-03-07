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
end
