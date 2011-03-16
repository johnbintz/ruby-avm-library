require 'avm/controlled_vocabulary'

module AVM
  module ImageType
    TERMS = %w{Observation Artwork Photographic Planetary Simulation Chart Collage}

    include ControlledVocabulary
  end
end

