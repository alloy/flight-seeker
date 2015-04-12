module FlightSeeker
  class AwardProgram
    def initialize(program_level, parent_award_program)
      @program_level, @parent_award_program = program_level, parent_award_program
    end

    def itinerary_level_mileage(itinerary)
      mileage = 0
      if @parent_award_program
        mileage += @parent_award_program.itinerary_level_mileage(itinerary)
      end
      mileage
    end

    def itinerary_award_mileage(itinerary)
      mileage = 0
      if @parent_award_program
        mileage += @parent_award_program.itinerary_award_mileage(itinerary)
      end
      mileage
    end

    class FrequentFlyer < AwardProgram
      def itinerary_level_mileage(itinerary)
        super + itinerary_booking_code_mileage(itinerary)
      end

      def itinerary_award_mileage(itinerary)
        super + itinerary_booking_code_mileage(itinerary)
      end

      def segment_mileage(segment)
        segment.mileage
      end

      def itinerary_booking_code_mileage(itinerary)
        itinerary.trips.inject(0) do |itinerary_sum, trip|
          itinerary_sum + trip.segments.inject(0) do |trip_sum, segment|
            trip_sum + (segment_booking_code_multiplier(segment) * segment_mileage(segment))
          end
        end
      end

      def segment_booking_code_multiplier(segment)
        if multiplier = send(segment.carrier.iata_designator, segment)
          multiplier
        else
          $stderr.puts "[!] Unknown multiplier for: #{segment.inspect}"
          -1
        end
      end
    end

    class FlyingBlue < FrequentFlyer
      # Minimum mileages

      CARRIERS_WITH_MINIMUM_MILEAGE = {
        :national => {
          'KL' => true,
          'AF' => true,
        },
        :international => {
          'KL' => true,
          'AF' => true,
        }
      }

      def carrier_has_minimum_mileage?(segment, type)
        iata_designator = segment.carrier.iata_designator
        unless CARRIERS_WITH_MINIMUM_MILEAGE[type].has_key?(iata_designator)
          $stderr.puts "[!] Unknown whether carrier has a minimum #{type} mileage: #{segment.inspect}"
        end
        CARRIERS_WITH_MINIMUM_MILEAGE[type][iata_designator]
      end

      def segment_mileage(segment)
        mileage = segment.mileage
        if mileage < 500 && segment.national? && carrier_has_minimum_mileage?(segment, :national)
          mileage = 500
        elsif mileage < 750 && segment.international? && carrier_has_minimum_mileage?(segment, :international)
          mileage = 750
        end
        mileage
      end

      # Program awards

      def program_level_bonus
        case @program_level
        when :silver
          0.5
        when :gold
          0.75
        when :platinum
          1
        else
          0
        end
      end

      def itinerary_award_mileage(itinerary)
        super + (program_level_bonus * itinerary.mileage)
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

    class FlyingBlue
      # Gold card:
      #
      # https://www.americanexpress.com/nl/content/flying-blue-gold-card/
      #
      # * Trips bought through either KLM or Air France: 1.5 award and level mile per euro.
      #   (To be able to buy a trip online or on the phone the itinerary needs to include at least one segment operated
      #   by KLM, Air France, or Delta Airlines.)
      #
      # * All other expenses (including tickets bought for other SkyTeam operated itineraries): 1 award mile per euro.
      #   TODO This still needs to be implemented.
      #
      class AmericanExpress < AwardProgram
        CARRIERS = %w{ KL AF DL }

        def includes_one_of_required_carriers?(itinerary)
          itinerary.trips.any? do |trip|
            trip.segments.any? do |segment|
              CARRIERS.include?(segment.carrier.iata_designator)
            end
          end
        end

        def program_level_bonus
          case @program_level
          when :gold
            1.5
          end
        end

        def itinerary_level_mileage(itinerary)
          mileage = super
          if includes_one_of_required_carriers?(itinerary)
            mileage += (program_level_bonus * itinerary.price)
          end
          mileage
        end

        def itinerary_award_mileage(itinerary)
          mileage = super
          if includes_one_of_required_carriers?(itinerary)
            mileage += (program_level_bonus * itinerary.price)
          end
          mileage
        end
      end
    end

  end
end

