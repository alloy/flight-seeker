require 'bacon'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'flight_seeker'

module FlightSeeker
  describe AwardProgram do
    before do
      @itinerary = Itinerary.new({
       "saleTotal"=>"EUR709.93",
       "slice"=>
        [{"kind"=>"qpxexpress#sliceInfo",
          "duration"=>954,
          "segment"=>
           [{"kind"=>"qpxexpress#segmentInfo",
             "duration"=>475,
             "flight"=>{"carrier"=>"KL", "number"=>"6034"},
             "id"=>"GHd2JS9avjGKQgiu",
             "cabin"=>"COACH",
             "bookingCode"=>"L",
             "bookingCodeCount"=>9,
             "marriedSegmentGroup"=>"2",
             "leg"=>
              [{"kind"=>"qpxexpress#legInfo",
                "id"=>"LORKvrKK0ie0N58H",
                "aircraft"=>"333",
                "arrivalTime"=>"2015-04-19T09:45+02:00",
                "departureTime"=>"2015-04-18T19:50-04:00",
                "origin"=>"DTW",
                "destination"=>"AMS",
                "originTerminal"=>"EM",
                "duration"=>475,
                "operatingDisclosure"=>"OPERATED BY DELTA",
                "mileage"=>3927,
                "meal"=>"Dinner",
                "secure"=>true}]},
            {"kind"=>"qpxexpress#segmentInfo",
             "duration"=>99,
             "flight"=>{"carrier"=>"AF", "number"=>"8830"},
             "id"=>"GneMPM3ixkd6cxIH",
             "cabin"=>"COACH",
             "bookingCode"=>"V",
             "bookingCodeCount"=>9,
             "marriedSegmentGroup"=>"1",
             "leg"=>
              [{"kind"=>"qpxexpress#legInfo",
                "id"=>"LhZx5AC75luBiXBc",
                "aircraft"=>"M88",
                "arrivalTime"=>"2015-04-13T17:09-04:00",
                "departureTime"=>"2015-04-13T15:30-04:00",
                "origin"=>"DTW",
                "destination"=>"LGA",
                "originTerminal"=>"EM",
                "destinationTerminal"=>"D",
                "duration"=>99,
                "operatingDisclosure"=>"OPERATED BY DELTA",
                "mileage"=>500,
                "secure"=>true}]}]},
         {"kind"=>"qpxexpress#sliceInfo",
          "duration"=>655,
          "segment"=>
           [{"kind"=>"qpxexpress#segmentInfo",
             "duration"=>126,
             "flight"=>{"carrier"=>"KL", "number"=>"6921"},
             "id"=>"GV6iWm988xOPPVDA",
             "cabin"=>"COACH",
             "bookingCode"=>"V",
             "bookingCodeCount"=>9,
             "marriedSegmentGroup"=>"2",
             "leg"=>
              [{"kind"=>"qpxexpress#legInfo",
                "id"=>"L5sSWhGU4ZlgT9Ii",
                "aircraft"=>"M88",
                "arrivalTime"=>"2015-04-18T18:56-04:00",
                "departureTime"=>"2015-04-18T16:50-04:00",
                "origin"=>"LGA",
                "destination"=>"DTW",
                "originTerminal"=>"D",
                "destinationTerminal"=>"EM",
                "duration"=>126,
                "operatingDisclosure"=>"OPERATED BY DELTA",
                "mileage"=>500,
                "secure"=>true}],
             "connectionDuration"=>54},
            {"kind"=>"qpxexpress#segmentInfo",
             "duration"=>475,
             "flight"=>{"carrier"=>"KL", "number"=>"6034"},
             "id"=>"GHd2JS9avjGKQgiu",
             "cabin"=>"COACH",
             "bookingCode"=>"V",
             "bookingCodeCount"=>9,
             "marriedSegmentGroup"=>"2",
             "leg"=>
              [{"kind"=>"qpxexpress#legInfo",
                "id"=>"LORKvrKK0ie0N58H",
                "aircraft"=>"333",
                "arrivalTime"=>"2015-04-19T09:45+02:00",
                "departureTime"=>"2015-04-18T19:50-04:00",
                "origin"=>"DTW",
                "destination"=>"AMS",
                "originTerminal"=>"EM",
                "duration"=>475,
                "operatingDisclosure"=>"OPERATED BY DELTA",
                "mileage"=>3927,
                "meal"=>"Dinner",
                "secure"=>true}]}]}]
      })

      # <price:709.93 segments:4 mileage:8854 duration:1310 trips:
      #   <AMS-LGA duration:655 segments:
      #     <KL booking-code:L mileage:3927 leg:AMS-DTW european:false national:false>
      #     <AF booking-code:V mileage:500  leg:DTW-LGA european:false national:true>
      #   >,
      #   <LGA-AMS duration:655 segments:
      #     <KL booking-code:V mileage:500  leg:LGA-DTW european:false national:true>,
      #     <KL booking-code:V mileage:3927 leg:DTW-AMS european:false national:false>
      #   >
      # >
    end

    describe AwardProgram::FrequentFlyer do
      before do
        # Using FlyingBlue here because we do need a class that implements multipliers for the airlines in the
        # itinerary. If it turns out that other frequent flyer programs do not calculate the same base level and award
        # mileage, then this needs to be changed.
        @base_award_program = AwardProgram::FlyingBlue.new(nil, nil)
      end

      %w{ level award }.each do |type|
        it "applies #{type} mileage based on the booking codes of the segments" do
          expected = 0
          # First trip
          expected += 3927 * 0.5
          expected += 500  * 0.25
          # Second trip
          expected += 500  * 0.25
          expected += 3927 * 0.25

          @base_award_program.send("itinerary_#{type}_mileage", @itinerary).should == expected
        end
      end

      describe AwardProgram::FlyingBlue do
        before do
          @flying_blue = AwardProgram::FlyingBlue.new(:silver, nil)
        end

        it 'does not award extra level mileage' do
          expected = @base_award_program.itinerary_level_mileage(@itinerary)
          @flying_blue.itinerary_level_mileage(@itinerary).should == expected
        end

        it 'adds extra award mileage based on the FlyingBlue level' do
          expected = @base_award_program.itinerary_award_mileage(@itinerary)
          expected += 8854 * 0.5
          @flying_blue.itinerary_award_mileage(@itinerary).should == expected
        end

        describe AwardProgram::FlyingBlue::AmericanExpress do
          describe 'when buying an itinerary from KLM or Air France, that includes a flight operated by KL, AF, or DL' do
            before do
              @card_award_program = AwardProgram::FlyingBlue::AmericanExpress.new(:gold, @flying_blue)
            end

            %w{ level award }.each do |type|
              it "adds extra #{type} mileage based on the itinerary price" do
                expected = @flying_blue.send("itinerary_#{type}_mileage", @itinerary)
                expected += 709.93 * 1.5
                @card_award_program.send("itinerary_#{type}_mileage", @itinerary).should == expected
              end
            end
          end
        end
      end
    end
  end
end

