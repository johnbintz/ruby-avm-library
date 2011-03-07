require 'spec_helper'
require 'avm/image'

describe AVM::Image do
  let(:image) { self.class.describes.new }

  subject { image }

  describe '#initialize' do
    it { should be_a_kind_of(AVM::Image) }

    its(:creator) { should be_a_kind_of(AVM::Creator) }
  end
end

