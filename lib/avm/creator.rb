module AVM
  class Creator
    def initialize
      @options = {}
    end

    def merge!(hash)
      @options.merge!(hash)
    end

    def method_missing(key, *opts)
      if key.to_s[-1..-1] == '='
        @options[key.to_s[0..-2].to_sym] = opts.first
      else
        @options[key]
      end
    end
  end
end

