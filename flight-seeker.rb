# Download airports.dat file from http://openflights.org/data.html.

#require 'active_support'
require 'csv'
require 'json'
require 'rest'
require 'terminal-table'
require 'digest/sha2'
require 'fileutils'

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

class AwardProgram
  def initialize(program_level)
    @program_level = program_level
  end

  def level_mileage_for(segment)
    multiplier_for(segment) * segment.mileage
  end

  def award_mileage_for(segment)
    multiplier_for(segment) * segment.mileage
  end

  def multiplier_for(segment)
    if multiplier = send(segment.carrier.iata_designator, segment)
      multiplier
    else
      $stderr.puts "[!] Unknown multiplier for: #{segment.inspect}"
      -1
    end
  end

  class FlyingBlue < AwardProgram
    def program_level_bonus
      case @program_level
      when :ivory
        0
      when :silver
        0.5
      when :gold
        0.75
      when :platinum
        1
      end
    end

    def award_mileage_for(segment)
      super + (program_level_bonus * segment.mileage)
    end

    # http://www.flyingblue.com/earn-and-spend-miles/airlines/partner/39/klm.html
    def KL(segment)
      if segment.european?
        case segment.booking_code
        when 'J', 'C', 'D', 'I', 'Z'
          2.5
        when 'Y', 'B', 'M'
          1
        when 'U', 'K', 'H', 'W'
          0.75
        when 'L', 'Q', 'S', 'A'
          0.5
        when 'T', 'E', 'N', 'R', 'G', 'V'
          0.25
        when 'O', 'X'
          0
        end
      else
        case segment.booking_code
        when 'J', 'C'
          1.75
        when 'D', 'I'
          1.5
        when 'Z'
          1.25
        when 'Y', 'B', 'M', 'U'
          1
        when 'K'
          0.75
        when 'H', 'L', 'Q'
          0.5
        when 'T', 'E', 'N', 'R', 'G', 'V'
          0.25
        end
      end
    end

    # http://www.flyingblue.com/earn-and-spend-miles/airlines/partner/14/air-france.html
    def AF(segment)
      if segment.european?
        case segment.booking_code
        when 'J', 'C', 'D', 'I', 'Z'
          2.5
        when 'Y', 'B', 'M'
          2
        when 'U'
          1
        when 'K', 'H'
          0.75
        when 'L', 'Q'
          0.5
        when 'T', 'E', 'N', 'R', 'X', 'V'
          0.25
        when 'G'
          0
        end
      else
        case segment.booking_code
        when 'P', 'F'
          3
        when 'J', 'C'
          1.75
        when 'D', 'I'
          1.5
        when 'Z'
          1.25
        when 'W', 'S'
          1.25
        when 'A'
          1
        when 'Y', 'B', 'M', 'U'
          1
        when 'K'
          0.75
        when 'H', 'L', 'Q'
          0.5
        when 'T', 'N', 'R', 'G', 'V'
          0.25
        end
      end
    end

    # http://www.flyingblue.com/earn-and-spend-miles/airlines/partner/168/aeroflot.html
    def SU(segment)
      case segment.booking_code
      when 'J', 'C', 'D'
        1.5
      when 'I', 'Z'
        1.25
      when 'W', 'S'
        1.25
      when 'A'
        1
      when 'Y', 'B'
        1
      when 'M', 'U'
        0.75
      when 'H', 'K'
        0.5
      when 'L', 'T', 'Q', 'N', 'R', 'E', 'P'
        0.25
      when 'O', 'X', 'F', 'G', 'V'
        0
      end
    end

    # http://www.flyingblue.com/earn-and-spend-miles/airlines/partner/172/air-europa.html
    def UX(segment)
      if segment.national?
      elsif segment.european?
        case segment.booking_code
        when 'J'
          1.75
        when 'C', 'D', 'I'
          1
        when 'Y', 'B', 'M'
          1
        when 'L'
          0.75
        when 'K', 'V', 'E', 'H'
          0.5
        when 'Q', 'R', 'S', 'U', 'T', 'F'
          0.25
        end
      else
        case segment.booking_code
        when 'J'
          1.50
        when 'C', 'D', 'I'
          1
        when 'Y', 'B', 'M'
          1
        when 'L'
          0.75
        when 'K', 'V', 'H', 'E'
          0.5
        when 'Q', 'R', 'S', 'U', 'T', 'F'
          0.25
        end
      end
    end
  end
end

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

require 'pp'

module QPX
  ENDPOINT = "https://www.googleapis.com/qpxExpress/v1/trips/search?key=#{ENV['QPX_EXPRESS_API_KEY']}"

  def self.search_round_trip(alliance_or_airlines, origin, destination, depart_date, return_date, sale_country, max_price)
    airlines = alliance_or_airlines.to_a.map(&:iata_designator)
    response = request(airlines, origin, destination, depart_date, return_date, sale_country, max_price)

    #response = JSON.parse(File.read('ams-nyc-12-18-april.json'))
    #response = JSON.parse(File.read('ams-lga-13-17-april.json'))

    response['trips']['tripOption'].map do |trip_option_payload|
      Itinerary.new(trip_option_payload)
    end
  end

  private

  def self.request(airlines, origin, destination, depart_date, return_date, sale_country, max_price)
    post({
      "request" => {
        "passengers" => {
          "kind" => "qpxexpress#passengerCounts",
          "adultCount" => 1,
          "childCount" => 0,
          "infantInLapCount" => 0,
          "infantInSeatCount" => 0,
          "seniorCount" => 0
        },
        "slice" => [
          {
            "kind" => "qpxexpress#sliceInput",
            "origin" => origin,
            "destination" => destination,
            "date" => depart_date,
            "permittedCarrier" => airlines,
            "maxStops" => 100,
          },
          {
            "kind" => "qpxexpress#sliceInput",
            "origin" => destination,
            "destination" => origin,
            "date" => return_date,
            "permittedCarrier" => airlines,
            "maxStops" => 100,
          }
        ],
        "maxPrice" => max_price,
        "saleCountry" => sale_country,
        "refundable" => false,
        "solutions" => 500 # max 500
      }
    })
  end

  def self.post(payload)
    json = payload.to_json
    cache_file = "cache/#{Digest::SHA2.hexdigest(json)}.json"
    if File.exist?(cache_file)
      puts "[!] Cached result: #{cache_file}"
      JSON.parse(File.read(cache_file))
    else
      response = REST.post(ENDPOINT, json, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
      FileUtils.mkdir_p('cache')
      File.write(cache_file, response.body)
      JSON.parse(response.body)
    end
  end
end

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: flight-seeker.rb [options]"

  opts.on("--sort=FIELDS", "Sort by field indices (comma separated, negative for reverse sort)") do |fields|
    options[:sort] = fields.split(',').map(&:to_i)
    if options[:sort].any?(&:zero?)
      raise "Sort fields may not be 0. Sorting is 1-based."
    end
  end
end.parse!

#p Alliance.sky_team

price = 'EUR1000'

#itineraries = QPX.search_round_trip(Alliance.sky_team, 'AMS', 'LGA', '2015-04-12', '2015-04-18', 'NL', price)
itineraries = QPX.search_round_trip(Alliance.sky_team, 'AMS', 'LGA', '2015-04-13', '2015-04-18', 'NL', price)
#itineraries = QPX.search_round_trip(Alliance.sky_team, 'AMS', 'LGA', '2015-04-13', '2015-04-17', 'NL', price)

award_program = AwardProgram::FlyingBlue.new(:silver)

def minutes_to_words(minutes)
  [[60, :m], [24, :h], [1000, :d]].map do |count, name|
    if minutes > 0
      minutes, n = minutes.divmod(count)
      "#{n.to_i}#{name}"
    end
  end.compact.reverse.join
end

def currency_symbol_for(price)
  case price.match(/^[A-Z]{3}/)[0]
  when 'EUR'
    '€'
  else
    raise "TODO: #{currency}"
  end
end

currency = currency_symbol_for(price)

rows = itineraries.map do |itinerary|
  [itinerary.price, itinerary.segment_count, itinerary.mileage, itinerary.level_mileage(award_program), itinerary.cents_per_level_mile(award_program), itinerary.award_mileage(award_program), itinerary.cents_per_award_mile(award_program), itinerary.trips.first.to_s, itinerary.trips.first.duration, itinerary.trips.last.to_s, itinerary.trips.last.duration]
end

if options[:sort]
  rows.sort! do |row_a, row_b|
    lhs, rhs = [], []
    options[:sort].each do |column|
      # Sorting is 1-based, because we can't have -0 with Fixnum.
      index = column.abs - 1
      if column >= 0
        lhs << row_a[index]
        rhs << row_b[index]
      else
        lhs << row_b[index]
        rhs << row_a[index]
      end
    end
    lhs <=> rhs
  end
end

table = Terminal::Table.new(:headings => ['Price', 'Segments', 'Mileage', 'Level Mileage', 'CPM', 'Award Mileage', 'CPM', 'Outbound', 'Duration', 'Inbound', 'Duration'])
rows.each do |row|
  price, segments, mileage, level_mileage, level_cpm, award_mileage, award_cpm, outbound, outbound_duration, inbound, inbound_duration = row
  table << ["#{currency}#{price}", segments, mileage, level_mileage, '%.2f¢' % level_cpm, award_mileage, '%.2f¢' % award_cpm, outbound, minutes_to_words(outbound_duration), inbound, minutes_to_words(inbound_duration)]
  table.add_separator unless row == rows.last
end
puts table
