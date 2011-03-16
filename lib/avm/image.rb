require 'avm/creator'
require 'avm/xmp'
require 'avm/image_type'
require 'avm/image_quality'
require 'avm/spatial_quality'
require 'avm/coordinate_system_projection'
require 'avm/coordinate_frame'
require 'avm/observation'

module AVM
  class Image
    DUBLIN_CORE_FIELDS = [ :title, :description ]

    AVM_SINGLE_FIELDS = [ 
      'Distance.Notes',
      'Spectral.Notes',
      'ReferenceURL',
      'Credit',
      'Date',
      'ID',
      'Type',
      'Image.ProductQuality',
      'Spatial.Equinox',
      'Spatial.Rotation',
      'Spatial.Notes',
      'Spatial.FITSheader',
      'Spatial.Quality',
      'Spatial.CoordsystemProjection',
      'Spatial.CDMatrix',
      'Spatial.Scale',
      'Spatial.ReferencePixel',
      'Spatial.ReferenceDimension',
      'Spatial.ReferenceValue',
      'Spatial.Equinox',
      'Spatial.CoordinateFrame'
    ]

    AVM_SINGLE_METHODS = [ 
      :distance_notes,
      :spectral_notes,
      :reference_url,
      :credit,
      :date,
      :id,
      :type,
      :quality,
      :spatial_equinox,
      :spatial_rotation,
      :spatial_notes,
      :fits_header,
      :spatial_quality,
      :coordinate_system_projection,
      :spatial_cd_matrix,
      :spatial_scale,
      :reference_pixel,
      :reference_dimension,
      :reference_value,
      :equinox,
      :coordinate_frame
    ]

    AVM_SINGLE_MESSAGES = [
      :distance_notes, 
      :spectral_notes, 
      :reference_url, 
      :credit, 
      :string_date, 
      :id, 
      :image_type, 
      :image_quality,
      :spatial_equinox,
      :spatial_rotation,
      :spatial_notes,
      :fits_header,
      :spatial_quality,
      :coordinate_system_projection,
      :spatial_cd_matrix,
      :spatial_scale,
      :reference_pixel,
      :reference_dimension,
      :reference_value,
      :equinox,
      :coordinate_frame
    ]

    AVM_SINGLES = AVM_SINGLE_FIELDS.zip(AVM_SINGLE_METHODS)

    AVM_TO_FLOAT = [ 
      :spatial_rotation,
      :spatial_cd_matrix,
      :spatial_scale,
      :reference_pixel,
      :reference_dimension,
      :reference_value
    ]

    attr_reader :creator, :observations

    def initialize(options = {})
      @creator = AVM::Creator.new(self)
      @options = options

      AVM_TO_FLOAT.each do |field| 
        if @options[field]
          case @options[field]
          when Array
            @options[field].collect!(&:to_f)
          else
            @options[field] = @options[field].to_f
          end
        end
      end

      @observations = []
    end

    def create_observation(options)
      observation = Observation.new(self, options)
      @observations << observation
      observation
    end

    def to_xml
      document = AVM::XMP.new

      creator.add_to_document(document)
      Observation.add_to_document(document, observations)

      document.get_refs do |refs|
        DUBLIN_CORE_FIELDS.each do |field|
          refs[:dublin_core].add_child(%{<dc:#{field}>#{alt_li_tag(send(field))}</dc:#{field}>})
        end

        refs[:photoshop].add_child(%{<photoshop:Headline>#{headline}</photoshop:Headline>})

        AVM_SINGLE_FIELDS.zip(AVM_SINGLE_MESSAGES).each do |tag, message|
          value = send(message)
          refs[:avm].add_child(%{<avm:#{tag}>#{value.to_s}</avm:#{tag}>}) if value
        end

        distance_nodes = []
        distance_nodes << rdf_li(light_years) if light_years
        if redshift
          distance_nodes << rdf_li('-') if distance_nodes.empty?
          distance_nodes << rdf_li(redshift)
        end

        if !distance_nodes.empty?
          refs[:avm].add_child(%{<avm:Distance><rdf:Seq>#{distance_nodes.join}</rdf:Seq></avm:Distance>})
        end
      end

      document.doc
    end

    def id
      @options[:id]
    end
    
    def image_type
      cv_class_instance_for(AVM::ImageType, :type)
    end

    def image_quality
      cv_class_instance_for(AVM::ImageQuality, :quality)
    end

    def spatial_quality
      cv_class_instance_for(AVM::SpatialQuality, :spatial_quality)
    end

    def coordinate_frame
      cv_class_instance_for(AVM::CoordinateFrame, :coordinate_frame)
    end

    def coordinate_system_projection
      cv_class_instance_for(AVM::CoordinateSystemProjection, :coordinate_system_projection)
    end

    def date
      (Time.parse(@options[:date]) rescue nil)
    end

    def string_date
      return nil if !date
      date.strftime('%Y-%m-%d')
    end

    def distance
      [ light_years, redshift ]
    end

    def self.from_xml(string)
      document = AVM::XMP.from_string(string)

      options = {}

      document.get_refs do |refs|
        DUBLIN_CORE_FIELDS.each do |field|
          if node = refs[:dublin_core].at_xpath(".//dc:#{field}//rdf:li[1]")
            options[field] = node.text
          end
        end

        AVM_SINGLES.each do |tag, field|
          if node = refs[:avm].at_xpath("./avm:#{tag}")
            if !(list_items = node.search('.//rdf:li')).empty?
              options[field] = list_items.collect(&:text)
            else
              options[field] = node.text
            end
          end
        end

        if node = refs[:photoshop].at_xpath('./photoshop:Headline')
          options[:headline] = node.text
        end

        if node = refs[:avm].at_xpath('./avm:Distance')
          list_values = node.search('.//rdf:li').collect { |li| li.text }

          case list_values.length
          when 1
            options[:light_years] = list_values.first
          when 2
            options[:light_years] = (list_values.first == '-') ? nil : list_values.first
            options[:redshift] = list_values.last
          end
        end
      end

      image = new(options)
      image.creator.from_xml(self, document)
      Observation.from_xml(image, document)
      image
    end

    def method_missing(method)
      @options[method]
    end

    private
      def alt_li_tag(text)
        %{<rdf:Alt><rdf:li xml:lang="x-default">#{text}</rdf:li></rdf:Alt>}
      end

      def rdf_li(text)
        %{<rdf:li>#{text}</rdf:li>}
      end

      def cv_class_instance_for(mod, field)
        (mod.const_get(@options[field].to_sym).new rescue nil)
      end
  end
end

