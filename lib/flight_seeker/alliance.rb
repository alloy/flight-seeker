module FlightSeeker
  class Alliance
    MAPPINGS = {
      'SKYTEAM' => {
        'name' => 'SkyTeam',
        'iata_airline_designators' => ['SU', 'AR', 'AM', 'UX', 'AF', 'AZ', 'CI', 'MU', 'CZ', 'OK', 'DL', 'GA', 'KQ', 'KL', 'KE', 'ME', 'SV', 'RO', 'VN', 'MF'],
      }
    }

    def self.sky_team
      @sky_team ||= new('SKYTEAM')
    end

    attr_reader :qpx_alliance_code

    def initialize(qpx_alliance_code)
      @qpx_alliance_code = qpx_alliance_code
    end

    def inspect
      "<#{name} airlines:#{airlines.map(&:inspect).join(', ')}>"
    end

    def name
      MAPPINGS[@qpx_alliance_code]['name']
    end

    def iata_airline_designators
      MAPPINGS[@qpx_alliance_code]['iata_airline_designators']
    end

    def airlines
      @airlines ||= iata_airline_designators.map { |iata| Airline.for_iata_designator(iata) }
    end

    alias_method :to_a, :airlines
  end
end

