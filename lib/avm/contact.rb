module AVM
  class Contact
    FIELD_MAP = {
      :zip => :postal_code,
      :state => :state_province,
      :province => :state_province
    }

    attr_accessor :primary

    def initialize(info)
      @info = Hash[info.collect { |key, value| [ FIELD_MAP[key] || key, value ] }]
      @primary = false
    end

    def method_missing(key)
      @info[FIELD_MAP[key] || key]
    end

    def <=>(other)
      self.name <=> other.name
    end
  end
end
