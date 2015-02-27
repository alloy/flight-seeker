require 'csv'

module FlightSeeker
  class Airport
    INSTANCES = {}

    def self.for_iata_designator(iata_designator)
      INSTANCES[iata_designator]
    end

    attr_reader :iata_designator, :name, :city, :country, :tz_timezone

    def initialize(iata_designator, name, city, country, tz_timezone)
      @iata_designator, @name, @city, @country, @tz_timezone = iata_designator, name, city, country, tz_timezone
    end

    def inspect
      iata_designator
    end

    def continent
      @continent ||= tz_timezone.split('/').first.to_sym
    end

    CSV.foreach('airports.dat') do |line|
      _, name, city, country, iata_designator, icao_designator, latitude, longitude, altitude, timezone, dst, tz_timezone = *line
      Airport::INSTANCES[iata_designator] = Airport.new(iata_designator, name, city, country, tz_timezone)
    end
  end
end

