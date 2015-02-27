require 'terminal-table'

module FlightSeeker
  class View
    attr_reader :itineraries, :award_program, :options

    def initialize(itineraries, award_program, options)
      @itineraries, @award_program, @options = itineraries, award_program, options
    end

    def rows
      rows = itineraries.map do |itinerary|
        #[itinerary.price, itinerary.segment_count, itinerary.mileage, award_program.itinerary_level_mileage(itinerary), itinerary.cents_per_level_mile(award_program), award_program.itinerary_award_mileage(itinerary), itinerary.cents_per_award_mile(award_program), itinerary.trips.first.to_s, itinerary.trips.first.duration, itinerary.trips.last.to_s, itinerary.trips.last.duration]
        [itinerary.price, itinerary.segment_count, itinerary.mileage, award_program.itinerary_level_mileage(itinerary), 0, award_program.itinerary_award_mileage(itinerary), 0, itinerary.trips.first.to_s, itinerary.trips.first.duration, itinerary.trips.last.to_s, itinerary.trips.last.duration]
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
      rows
    end

    def table
      table = Terminal::Table.new(:headings => ['Price', 'Segments', 'Mileage', 'Level Mileage', 'CPM', 'Award Mileage', 'CPM', 'Outbound', 'Duration', 'Inbound', 'Duration'])
      rows.each do |row|
        price, segments, mileage, level_mileage, level_cpm, award_mileage, award_cpm, outbound, outbound_duration, inbound, inbound_duration = row
        table << ["#{currency}#{price}", segments, mileage, level_mileage, '%.2f¢' % level_cpm, award_mileage, '%.2f¢' % award_cpm, outbound, minutes_to_words(outbound_duration), inbound, minutes_to_words(inbound_duration)]
        table.add_separator unless row == rows.last
      end
      table
    end

    private

    def currency
      itineraries.first.currency
    end

    def minutes_to_words(minutes)
      [[60, :m], [24, :h], [1000, :d]].map do |count, name|
        if minutes > 0
          minutes, n = minutes.divmod(count)
          "#{n.to_i}#{name}"
        end
      end.compact.reverse.join
    end
  end
end

