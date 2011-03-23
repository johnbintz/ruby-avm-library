module AVM
  # An individual observation by a single instrument w/ specific settings.
  # Astronomical images are made of one or more Observations.
  class Observation
    AVM_SINGLE_FIELDS = %w{Facility Instrument Spectral.ColorAssignment Spectral.Band Spectral.Bandpass Spectral.CentralWavelength Temporal.StartTime Temporal.IntegrationTime DatasetID}
    AVM_SINGLE_METHODS = [ :facility, :instrument, :color_assignment, :band, :bandpass, :wavelength, :string_start_time, :integration_time, :dataset_id ]
    AVM_SINGLES = AVM_SINGLE_FIELDS.zip(AVM_SINGLE_METHODS)

    attr_reader :image, :options

    def initialize(image, options = {})
      @image, @options = image, options
      @options[:start_time] = @options[:string_start_time] || @options[:start_time]
    end
  
    def method_missing(method)
      @options[method]
    end

    def wavelength
      (wavelength = @options[:wavelength]) ? wavelength.to_f : nil
    end

    def start_time
      (Time.parse(@options[:start_time]) rescue nil)
    end

    def string_start_time
      start_time ? start_time.strftime('%Y-%m-%dT%H:%M') : nil
    end

    def to_h
      Hash[@options.keys.reject { |key| key == :string_start_time }.collect { |key| [ key, send(key) ] }]
    end

    def self.from_xml(image, document)
      observation_parts = {}

      document.get_refs do |refs|
        AVM_SINGLES.each do |name, method|
          if node = refs[:avm].at_xpath(".//avm:#{name}")
            observation_parts[method] = node.text.split(';').collect(&:strip)
          end
        end
      end

      begin
        observation = {}

        observation_parts.each do |method, parts|
          if part = parts.shift
            observation[method] = part if part != '-'
          end
        end

        image.create_observation(observation) if !observation.empty?
      end while !observation.empty?
    end

    def self.add_to_document(document, observations)
      field_values = {}
      AVM_SINGLES.each do |name, method|
        observations.each do |observation|
          field_values[name] ||= []
          field_values[name] << (observation.send(method) || '-')
        end
      end

      document.get_refs do |refs|
        field_values.each do |name, value|
          refs[:avm].add_child(%{<avm:#{name}>#{value.join(',')}</avm:#{name}>})
        end
      end
    end
  end
end
