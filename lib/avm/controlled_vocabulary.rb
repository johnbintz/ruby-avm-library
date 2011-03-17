module AVM
  module ControlledVocabulary
    class << self
      def included(klass)
        klass::TERMS.each do |type|
          new_klass = Class.new do
            def to_s
              self.class.to_s.split('::').last
            end

            def ==(other)
              self.to_s == other.to_s
            end
          end

          klass.const_set(type.to_sym, new_klass)
        end
      end
    end
  end
end

