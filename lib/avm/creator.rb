require 'avm/contact'
require 'nokogiri'

module AVM
  class Creator
    attr_reader :contacts, :image

    IPTC_CORE_FIELDS = [ :address, :city, :state, :zip, :country ]
    PRIMARY_CONTACT_FIELDS = IPTC_CORE_FIELDS + [ :province, :postal_code ]
    IPTC_MULTI_FIELD_MAP = [ [ :telephone, 'CiTelWork' ], [ :email, 'CiEmailWork' ] ]
    IPTC_CORE_FIELD_ELEMENT_NAMES = %w{CiAdrExtadr CiAdrCity CiAdrRegion CiAdrPcode CiAdrCtry}
    IPTC_CORE_FIELDS_AND_NAMES = IPTC_CORE_FIELDS.zip(IPTC_CORE_FIELD_ELEMENT_NAMES)

    def initialize(image, given_contacts = [])
      @options = {}
      @contacts = given_contacts
      @image = image
    end

    def merge!(hash)
      @options.merge!(hash)
    end

    def length
      contacts.length
    end

    def [](which)
      contacts[which]
    end

    def to_a
      contacts.sort.collect(&:to_h)
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

    def add_to_document(document)
      document.get_refs do |refs|
        creator = refs[:dublin_core].add_child('<dc:creator><rdf:Seq></rdf:Seq></dc:creator>')

        list = creator.at_xpath('.//rdf:Seq')
        contact_info = refs[:iptc].add_child('<Iptc4xmpCore:CreatorContactInfo rdf:parseType="Resource" />').first

        contacts.sort.each do |contact| 
          list.add_child(contact.to_creator_list_element) 
        end

        if primary_contact
          IPTC_MULTI_FIELD_MAP.each do |key, element_name|
            contact_info.add_child "<Iptc4xmpCore:#{element_name}>#{contacts.sort.collect(&key).join(',')}</Iptc4xmpCore:#{element_name}>"
          end

          iptc_namespace = document.doc.root.namespace_scopes.find { |ns| ns.prefix == 'Iptc4xmpCore' }

          IPTC_CORE_FIELDS_AND_NAMES.each do |key, element_name|
            node = contact_info.document.create_element(element_name, primary_contact.send(key))
            node.namespace = iptc_namespace
            contact_info.add_child node
          end
        end
      end
    end

    def from_xml(image, document)
      contacts = []
      document.get_refs do |refs|
        refs[:dublin_core].search('.//rdf:li').each do |name|
          contacts << { :name => name.text }
        end

        IPTC_MULTI_FIELD_MAP.each do |key, element_name|
          if node = refs[:iptc].at_xpath("//Iptc4xmpCore:#{element_name}")
            node.text.split(',').collect(&:strip).each_with_index do |value, index|
              contacts[index][key] = value
            end
          end
        end

        IPTC_CORE_FIELDS_AND_NAMES.each do |key, element_name|
          if node = refs[:iptc].at_xpath("//Iptc4xmpCore:#{element_name}")
            contacts.each { |contact| contact[key] = node.text.strip }
          end
        end
      end

      if !(@contacts = contacts.collect { |contact| Contact.new(contact) }).empty?
        @contacts.first.primary = true
      end
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

