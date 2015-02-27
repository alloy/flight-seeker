module FlightSeeker
  class Airline
    # TODO Use data file from openflights as well?
    MAPPINGS = {
      'SU' => 'Aeroflot',
      'AR' => 'Aerolíneas Argentinas',
      'AM' => 'Aeroméxico',
      'UX' => 'Air Europa',
      'AF' => 'Air France',
      'AZ' => 'Alitalia',
      'CI' => 'China Airlines',
      'MU' => 'China Eastern',
      'CZ' => 'China Southern',
      'OK' => 'Czech Airlines',
      'DL' => 'Delta Air Lines',
      'GA' => 'Garuda Indonesia',
      'KQ' => 'Kenya Airways',
      'KL' => 'KLM',
      'KE' => 'Korean Air',
      'ME' => 'Middle East Airlines',
      'SV' => 'Saudia',
      'RO' => 'TAROM',
      'VN' => 'Vietnam Airlines',
      'MF' => 'XiamenAir',
    }

    def self.for_iata_designator(iata_designator)
      @instances ||= {}
      @instances[iata_designator] ||= new(iata_designator)
    end

    attr_reader :iata_designator

    def initialize(iata_designator)
      @iata_designator = iata_designator
    end

    def inspect
      "<#{@iata_designator}: #{name}>"
    end

    def name
      MAPPINGS[@iata_designator]
    end
  end
end

