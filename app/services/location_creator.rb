class LocationCreator
  attr_accessor :location
  attr_reader :type, :message, :status, :source

  def initialize(params)
    @source = params[:source]
    @type = params[:type]
    @location = Location.new
  end

  def call
    prepare_sources
    find_coordinates
    save_location
  rescue SocketError
    unresolved_ip_result
  rescue CoordinatesFinder::CoordinatesNotFound
    unresolved_coordinates_result
  # not really typical behavior, trying to save from dead db as requested :)
  rescue ActiveRecord::StatementInvalid, ActiveRecord::ConnectionTimeoutError
    unresolved_record_saving
  end

  private

  def prepare_sources
    SourcesPreparer.call(type, source, location)
  end

  def find_coordinates
    coordinates = coordinates_filler.call
    geolocation = ActiveRecord::Point.new(coordinates[:latitude].to_f, coordinates[:longitude].to_f)
    location.geolocation = geolocation
  end

  def save_location
    if location.save
      @location = LocationsBlueprint.render_as_hash(location)
      @message = 'Location was detected and saved'
      @status = :created
    elsif location.errors
      unresolved_record_saving(error: location.errors.full_messages.join(', '))
    end
  end

  def unresolved_ip_result
    @message = "unable to locate coordinates for IP address #{location.ip_address}"
    @location = {}
    @status = :unprocessable_entity
  end

  def unresolved_coordinates_result
    @message = 'unable to locate IP address'
    @location = {}
    @status = :unprocessable_entity
  end

  def unresolved_record_saving(error: nil)
    @message = 'Location was detected, but we were unable to save it'
    @message.concat(" because of: #{error}") if error
    @location = LocationsBlueprint.render_as_hash(location)
    @status = :ok
  end

  def coordinates_filler
    @coordinates_filler ||= CoordinatesFinder.new(location)
  end
end
