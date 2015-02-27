module FlightSeeker
  class TripQuery
    def self.from_trip_description(trip_description)
      match = trip_description.match(/^(\d{4}-\d{2}-\d{2})-(.+)/)
      date, remainder = match[1], match[2]
      unless date
        raise "[!] Invalid date format in `#{trip_description}'."
      end
      airports = remainder.split('-').map(&:upcase)
      airports.each do |airport|
        unless airport =~ /^[A-Z]{3}$/
          raise "[!] Not a valid airport IATA designator `#{airport}' in `#{trip_description}'."
        end
      end
      unless airports.size >= 2
        raise "[!] Less than 2 airports specified in `#{trip_description}'."
      end
      new(date, airports)
    end

    attr_reader :date, :airports

    def initialize(date, airports)
      @date, @airports = date, airports
    end

    Segment = Struct.new(:origin, :destination)

    def segments
      if airports.size == 2
        [Segment.new(*airports)]
      else
        airports[2..-1].inject([Segment.new(*airports.first(2))]) do |segments, airport|
          segments << Segment.new(segments.last.destination, airport)
        end
      end
    end
  end
end

