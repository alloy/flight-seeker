require 'flight_seeker/airline'

module FlightSeeker
  class Itinerary
    def initialize(payload)
      @payload = payload
    end

    def inspect
      "<price:#{price} segments:#{segment_count} mileage:#{mileage} duration:#{duration} trips:#{trips.map(&:inspect).join(', ')}>"
    end

    def trips
      @trips ||= @payload['slice'].map { |trip_payload| Trip.new(trip_payload) }
    end

    # TODO ugh, float money :-/
    def price
      @payload['saleTotal'].match(/(\d+(\.\d+)?)$/)[1].to_f
    end

    def currency
      currency = @payload['saleTotal'].match(/^[A-Z]{3}/)[0]
      case currency
      when 'EUR'
        '€'
      else
        raise "Unhandled currency: #{currency}"
      end
    end

    def segment_count
      trips.inject(0) { |sum, trip| sum + trip.segments.size }
    end

    def mileage
      trips.inject(0) { |sum, trip| sum + trip.mileage }
    end

    def level_mileage(award_program)
      trips.inject(0) { |sum, trip| sum + trip.level_mileage(award_program) }
    end

    def award_mileage(award_program)
      trips.inject(0) { |sum, trip| sum + trip.award_mileage(award_program) }
    end

    def cents_per_level_mile(award_program)
       (price * 100) / level_mileage(award_program)
    end

    def cents_per_award_mile(award_program)
      (price * 100) / award_mileage(award_program)
    end

    # In minutes
    def duration
      trips.inject(0) { |sum, trip| sum + trip.duration }
    end

    class Trip
      def initialize(payload)
        @payload = payload
      end

      def inspect
        "<#{segments.first.origin}-#{segments.last.destination} duration:#{duration} #{segments.map(&:inspect).join(', ')}>"
      end

      def to_s
        segments.map do |segment|
          "#{segment.origin.iata_designator}-(#{segment.carrier.iata_designator}/#{segment.booking_code})->"
        end.join << segments.last.destination.iata_designator
      end

      # In minutes
      def duration
        @payload['duration']
      end

      def segments
        @segments ||= @payload['segment'].map { |segment_payload| Segment.new(segment_payload) }
      end

      def airports
        segments.map(&:origin) << segments.last.destination
      end

      def mileage
        segments.inject(0) { |sum, segment| sum + segment.mileage }
      end

      def level_mileage(award_program)
        segments.inject(0) { |sum, segment| sum + segment.level_mileage(award_program) }
      end

      def award_mileage(award_program)
        segments.inject(0) { |sum, segment| sum + segment.award_mileage(award_program) }
      end

      class Segment
        def initialize(payload)
          @payload = payload
        end

        def inspect
          "<#{carrier.iata_designator} booking-code:#{booking_code} mileage:#{mileage} leg:#{origin.inspect}-#{destination.inspect}>"
        end

        def carrier
          Airline.for_iata_designator(@payload['flight']['carrier'])
        end

        def booking_code
          @payload['bookingCode']
        end

        def origin
          Airport.for_iata_designator(leg['origin'])
        end

        def destination
          Airport.for_iata_designator(leg['destination'])
        end

        def mileage
          leg['mileage']
        end

        def level_mileage(award_program)
          award_program.level_mileage_for(self)
        end

        def award_mileage(award_program)
          award_program.award_mileage_for(self)
        end

        def european?
          origin.continent == :Europe && destination.continent == :Europe
        end

        def national?
          origin.country == destination.country
        end

        private

        # TODO why can there be multiple legs in 1 segment?
        def leg
          raise "TODO" if @payload['leg'].size > 1
          @payload['leg'].first
        end
      end
    end
  end
end
