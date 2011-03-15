module AVM
  module ImageType
    %w{Observation Artwork Photographic Planetary Simulation Chart Collage}.each do |type|
      klass = Class.new do
        def to_s
          self.class.to_s.split('::').last
        end
      end

      AVM::ImageType.const_set(type.to_sym, klass)
    end
  end
end

