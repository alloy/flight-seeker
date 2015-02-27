require 'flight_seeker/airport'
require 'flight_seeker/award_program'
require 'flight_seeker/airline'
require 'flight_seeker/alliance'
require 'flight_seeker/itinerary'
require 'flight_seeker/trip_query'
require 'flight_seeker/view'

require 'digest/sha2'
require 'fileutils'

require 'json'
require 'rest'

module FlightSeeker
  QPX_ENDPOINT = "https://www.googleapis.com/qpxExpress/v1/trips/search?key=#{ENV['QPX_EXPRESS_API_KEY']}"

  def self.search(alliance_or_airlines, trip_queries, sale_country, max_price)
    airlines = alliance_or_airlines.to_a.map(&:iata_designator)
    response = request(airlines, trip_queries, sale_country, max_price)
    if trip_option_payloads = response['trips']['tripOption']
      trip_option_payloads.map do |trip_option_payload|
        Itinerary.new(trip_option_payload)
      end
    end
  end

  private

  def self.request(airlines, trip_queries, sale_country, max_price)
    slices = trip_queries.map do |trip_query|
      trip_query.segments.map do |segment|
        {
          "kind" => "qpxexpress#sliceInput",
          "origin" => segment.origin,
          "destination" => segment.destination,
          "date" => trip_query.date,
          "permittedCarrier" => airlines,
          "maxStops" => 100,
        }
      end
    end.flatten
    query = {
      "request" => {
        "passengers" => {
          "kind" => "qpxexpress#passengerCounts",
          "adultCount" => 1,
          "childCount" => 0,
          "infantInLapCount" => 0,
          "infantInSeatCount" => 0,
          "seniorCount" => 0
        },
        "slice" => slices,
        "saleCountry" => sale_country,
        "refundable" => false,
        "solutions" => 500 # max 500
      }
    }
    query['request']['maxPrice'] = max_price if max_price
    post(query)
  end

  def self.post(payload)
    json = payload.to_json
    cache_file = File.expand_path("../../cache/#{Digest::SHA2.hexdigest(json)}.json", __FILE__)
    if File.exist?(cache_file)
      puts "[!] Cached result: #{cache_file}"
      JSON.parse(File.read(cache_file))
    else
      response = REST.post(QPX_ENDPOINT, json, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
      FileUtils.mkdir_p(File.expand_path("../../cache", __FILE__))
      File.write(cache_file, response.body)
      JSON.parse(response.body)
    end
  end
end

