module AVM
  class Contact
    FIELD_MAP = {
      :zip => :postal_code,
      :state => :state_province,
      :province => :state_province
    }

    HASH_FIELDS = [ :name, :email, :telephone, :address, :city, :state, :postal_code, :country ]

    attr_accessor :primary

    def initialize(info)
      @info = Hash[info.collect { |key, value| [ FIELD_MAP[key] || key, value ] }]
      @primary = false
    end

    def method_missing(key)
      @info[FIELD_MAP[key] || key]
    end

    def <=>(other)
      return -1 if primary?
      self.name <=> other.name
    end

    def to_creator_list_element
      %{<rdf:li>#{self.name}</rdf:li>}
    end

    def primary?
      @primary
    end

    def to_h
      Hash[HASH_FIELDS.collect { |key| [ key, send(key) ] } ]
    end
  end
end
