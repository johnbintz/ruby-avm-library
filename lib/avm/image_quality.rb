module AVM
  module ImageQuality
    %w{Good Moderate Poor}.each do |type|
      klass = Class.new do
        def to_s
          self.class.to_s.split('::').last
        end
      end

      AVM::ImageQuality.const_set(type.to_sym, klass)
    end
  end
end

