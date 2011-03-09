require 'avm/contact'
require 'nokogiri'

module AVM
  class Creator
    attr_reader :contacts

    PRIMARY_CONTACT_FIELDS = [ :address, :city, :state, :province, :postal_code, :zip, :country ]

    def initialize
      @options = {}
      @contacts = []
    end

    def merge!(hash)
      @options.merge!(hash)
    end

    def method_missing(key, *opts)
      if key.to_s[-1..-1] == '='
        @options[key.to_s[0..-2].to_sym] = opts.first
      else
        if PRIMARY_CONTACT_FIELDS.include?(key)
          primary_contact_field key
        else
          @options[key]
        end
      end
    end

    def add_to_rdf(rdf)
      creator = rdf.add_child('<dc:creator><rdf:Seq></rdf:Seq></dc:creator>')
      
      list = creator.at_xpath('.//rdf:Seq')

      contacts.sort.each { |contact| list.add_child(contact.to_creator_list_element) }
    end

    def primary_contact
      @contacts.find(&:primary) || @contacts.sort.first
    end

    def create_contact(info)
      contact = Contact.new(info)
      contacts << contact
      contact
    end

    private
      def primary_contact_field(field)
        if contact = primary_contact
          contact.send(field)
        else
          nil
        end
      end
  end
end

