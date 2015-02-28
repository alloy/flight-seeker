require 'terminal-table'

module FlightSeeker
  class View
    class Row
      attr_reader :itinerary, :options

      def initialize(itinerary, options)
        @itinerary, @options = itinerary, options
      end

      def price
        itinerary.price
      end

      def segment_count
        itinerary.segment_count
      end

      def mileage
        itinerary.mileage
      end

      # TODO how is it really rounded?
      def level_mileage
        options[:award_program].itinerary_level_mileage(itinerary).to_i
      end

      # TODO how is it really rounded?
      def award_mileage
        options[:award_program].itinerary_award_mileage(itinerary).to_i
      end

      def fare_calculation
        itinerary.fare_calculation if options[:fare_calculation]
      end

      def cents_per_mile
        # TODO
        0
      end

      def trip_descriptions
        itinerary.trips.map { |trip| trip.to_s(options[:segment_info]) }
      end

      def trip_durations
        itinerary.trips.map(&:duration)
      end

      def trip_arrival_times
        itinerary.trips.map(&:arrival_time) if options[:arrival_time]
      end

      def values
        trips = trip_descriptions.zip(trip_durations)
        trips = trips.zip(trip_arrival_times) if options[:arrival_time]
        trips.flatten!
        columns = [price, segment_count, mileage, level_mileage, award_mileage, *trips]
        columns << fare_calculation if options[:fare_calculation]
        columns
      end

      # Formatting

      def formatted_price
        "#{itinerary.currency}#{price}"
      end

      def formatted_cents_per_mile
        '%.2f¢' % cents_per_mile
      end

      def formatted_trip_durations
        trip_durations.map do |duration|
          [[60, :m], [24, :h], [1000, :d]].map do |count, name|
            if duration > 0
              duration, n = duration.divmod(count)
              "#{n.to_i}#{name}"
            end
          end.compact.reverse.join
        end
      end

      def formatted_values
        trips = trip_descriptions.zip(formatted_trip_durations)
        trips = trips.zip(trip_arrival_times) if options[:arrival_time]
        trips.flatten!
        columns = [formatted_price, segment_count, mileage, level_mileage, award_mileage, *trips]
        columns << fare_calculation if options[:fare_calculation]
        columns
      end
    end

    attr_reader :itineraries, :options

    def initialize(itineraries, options)
      @itineraries, @options = itineraries, options
    end

    def rows
      unless @rows
        @rows = itineraries.map { |itinerary| Row.new(itinerary, options) }
        if options[:sort]
          mappings = rows.inject({}) { |h, row| h[row.values] = row; h }
          sorted_rows = mappings.keys

          sorted_rows.sort! do |row_a, row_b|
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

          @rows = mappings.values_at(*sorted_rows)
        end
      end
      @rows
    end

    def headings
      headings = [
        'Price',
        'Segments',
        'Mileage',
        'Level Mileage',
        #'CPM',
        'Award Mileage',
        #'CPM',
      ]
      itineraries.first.trips.size.times do
        headings << 'Trip'
        headings << 'Duration'
        headings << 'Arrival' if options[:arrival_time]
      end
      headings << 'Fare Calculation' if options[:fare_calculation]
      headings
    end

    def table
      table = Terminal::Table.new(:headings => headings)
      rows.each do |row|
        table << row.formatted_values
        table.add_separator unless row == rows.last
      end
      table
    end
  end
end

