require 'avm/creator'

module AVM
  class Image
    attr_reader :creator

    def initialize
      @creator = AVM::Creator.new
    end
  end
end

