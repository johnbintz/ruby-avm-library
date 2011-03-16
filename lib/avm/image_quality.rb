require 'avm/controlled_vocabulary'

module AVM
  module ImageQuality
    TERMS = %w{Good Moderate Poor}

    include AVM::ControlledVocabulary
  end
end

