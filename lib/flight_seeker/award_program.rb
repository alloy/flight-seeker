module FlightSeeker
  class AwardProgram
    def initialize(program_level, parent_award_program)
      @program_level, @parent_award_program = program_level.to_sym, parent_award_program
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

    class FlyingBlue
      class AmericanExpress < AwardProgram
      end
    end

  end
end

