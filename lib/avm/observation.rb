module AVM
  class Observation
    AVM_SINGLE_FIELDS = %w{Facility Instrument Spectral.ColorAssignment Spectral.Band Spectral.Bandpass Spectral.CentralWavelength Spectral.Notes Temporal.StartTime Temporal.IntegrationTime DatasetID}
    AVM_SINGLE_METHODS = [ :facility, :instrument, :color_assignment, :band, :bandpass, :wavelength, :notes, :string_start_time, :integration_time, :dataset_id ]
    AVM_SINGLES = AVM_SINGLE_FIELDS.zip(AVM_SINGLE_METHODS)

    attr_reader :image, :options

    def initialize(image, options = {})
      @image, @options = image, options
    end
  
    def method_missing(method)
      @options[method]
    end

    def start_time
      (Time.parse(@options[:start_time]) rescue nil)
    end

    def string_start_time
      start_time.strftime('%Y-%m-%dT%H:%M')
    end

    def self.add_to_document(document, observations)
      field_values = {}
      AVM_SINGLES.each do |name, method|
        observations.each do |observation|
          field_values[name] ||= []
          field_values[name] << observation.send(method)
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
