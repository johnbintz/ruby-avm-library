require 'avm/controlled_vocabulary'

module AVM
  module CoordinateFrame
    TERMS = %w{ICRS FK5 FK4 ECL GAL SGAL}

    include ControlledVocabulary
  end
end

