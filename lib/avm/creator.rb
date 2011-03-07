require 'avm/contact'

module AVM
  class Creator
    attr_reader :contacts

    def initialize
      @options = {}
      @contacts = []
    end

    def merge!(hash)
      @options.merge!(hash)
    end

    def address
      primary_contact_field :address
    end

    def method_missing(key, *opts)
      if key.to_s[-1..-1] == '='
        @options[key.to_s[0..-2].to_sym] = opts.first
      else
        @options[key]
      end
    end

    private
      def primary_contact_field(field)
        if contact = primary_contact
          contact.send(field)
        else
          nil
        end
      end

      def primary_contact
        @contacts.find(&:primary) || @contacts.sort.first
      end
  end
end

