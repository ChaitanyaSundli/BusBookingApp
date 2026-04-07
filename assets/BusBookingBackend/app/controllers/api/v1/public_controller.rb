module Api
  module V1
    class PublicController < BaseController
      class BookingRequestError < StandardError; end
      skip_before_action :authenticate_user!


      def stops
        query = params[:q].to_s.strip.downcase

        stops = RouteStop
          .where('LOWER(city_name) LIKE ?', "%#{query}%")
          .select(:city_name)
          .distinct
          .order(:city_name)
          .limit(10)

        render json: {
          message: 'Stops fetched successfully',
          data: stops.map { |stop| { city_name: stop.city_name } }
        }, status: :ok
      end

      def buses
        buses = Bus
          .where(bus_operator_id: params[:id])
          .select(:id, :bus_name, :bus_no, :bus_type, :deck, :total_seats)

        render json: {
          message: 'Buses fetched successfully',
          data: buses.as_json
        }, status: :ok
      end

      def base_trip_scope(source, destination, date)
        scope = Trip
          .joins(:route, bus: :bus_operator)
          .joins("INNER JOIN route_stops AS boarding ON boarding.route_id = routes.id")
          .joins("INNER JOIN route_stops AS drop ON drop.route_id = routes.id")
          .where("LOWER(TRIM(boarding.city_name)) = ?", source)
          .where("LOWER(TRIM(drop.city_name)) = ?", destination)
          .where("drop.km_from_source > boarding.km_from_source")
          .where(status: :scheduled)
          .where("available_seats > 0")
      
        scope = scope.where(travel_start_date: Date.parse(date)) if date.present?
      
        scope
      end
      
      def operator_trips
        source      = params[:source].to_s.strip.downcase
        destination = params[:destination].to_s.strip.downcase
        date        = params[:date].presence
        operator_id = params[:operator_id]
      
        return render json: { message: "operator_id required" }, status: :bad_request if operator_id.blank?
      
        trips = base_trip_scope(source, destination, date)
                  .where(buses: { bus_operator_id: operator_id })
                  .includes(:route, bus: :bus_operator)
                  .order(:departure_time)
      
        data = trips.map do |trip|
          route_stops = ordered_route_stops(trip.route)

          {
            id: trip.id,
            travel_start_date: trip.travel_start_date,
            departure_time: trip.departure_time,
            arrival_time: trip.arrival_time,
            available_seats: trip.available_seats,
            duration_mins: trip.route.estimated_duration_mins,
            price: calculate_fare(trip, trip.bus.bus_operator),
        
            bus: {
              id: trip.bus.id,
              name: trip.bus.bus_name,
              number: trip.bus.bus_no,
              type: trip.bus.bus_type,
              deck: trip.bus.deck
            },
          
            operator: {
              id: trip.bus.bus_operator.id,
              name: trip.bus.bus_operator.company_name
            },
            booking_context: {
              route_stops: route_stops,
              default_boarding_stop_id: route_stops.find { |stop| stop[:is_boarding_point] }&.dig(:id),
              default_drop_stop_id: route_stops.reverse.find { |stop| stop[:is_drop_point] }&.dig(:id)
            }
          }
        end
      
        render json: {
          message: "Trips fetched",
          count: data.size,
          data: data
        }
      end

      def operators
        source      = params[:source].to_s.strip.downcase
        destination = params[:destination].to_s.strip.downcase
        date        = params[:date].presence
      
        trips = base_trip_scope(source, destination, date)
                  .includes(bus: :bus_operator)
      
        grouped = trips.group_by { |t| t.bus.bus_operator }
      
        data = grouped.map do |operator, operator_trips|
          {
            operator_id: operator.id,
            operator_name: operator.company_name,
            total_buses: operator_trips.size,
            lowest_price: operator_trips.map { |t|
              calculate_fare(t, operator)
            }.compact.min || 0
          }
        end
      
        render json: {
          message: 'Operators fetched successfully',
          count: data.size,
          data: data
        }
      end


      def all_operators
        operators = BusOperator
          .where(is_verified: true)
          .includes(buses: [trips: :route])
          .order(:company_name)

        data = operators.map do |operator|
          upcoming_trips = Trip
            .joins(:bus)
            .where(buses: { bus_operator_id: operator.id })
            .where(status: :scheduled)
            .where('departure_time >= ?', Time.current)
            .order(:departure_time)

          {
            operator_id: operator.id,
            operator_name: operator.company_name,
            total_buses: operator.buses.count,
            active_trips: upcoming_trips.count,
            starting_price: upcoming_trips.map { |trip| calculate_fare(trip, operator) }.compact.min || 0,
            routes: upcoming_trips.includes(:route).limit(4).map { |trip| "#{trip.route.source_city} → #{trip.route.destination_city}" }.uniq
          }
        end

        render json: {
          message: 'All operators fetched successfully',
          count: data.size,
          data: data
        }, status: :ok
      end

      def operator_overview
        operator = BusOperator.includes(buses: :trips).find(params[:operator_id])

        scheduled_trips = Trip
          .joins(:bus, :route)
          .where(buses: { bus_operator_id: operator.id })
          .where(status: :scheduled)
          .where('departure_time >= ?', Time.current)
          .includes(:route, :bus)
          .order(:departure_time)

        render json: {
          message: 'Operator overview fetched successfully',
          data: {
            operator: {
              id: operator.id,
              name: operator.company_name,
              contact_email: operator.contact_email,
              verified: operator.is_verified,
              total_buses: operator.buses.count,
              active_trips: scheduled_trips.count
            },
            buses: operator.buses.map do |bus|
              {
                id: bus.id,
                name: bus.bus_name,
                number: bus.bus_no,
                type: bus.bus_type,
                deck: bus.deck,
                total_seats: bus.total_seats
              }
            end,
            scheduled_trips: scheduled_trips.map do |trip|
              {
                trip_id: trip.id,
                bus_id: trip.bus_id,
                bus_name: trip.bus.bus_name,
                bus_number: trip.bus.bus_no,
                source: trip.route.source_city,
                destination: trip.route.destination_city,
                departure_time: trip.departure_time,
                arrival_time: trip.arrival_time,
                available_seats: trip.available_seats,
                fare: calculate_fare(trip, operator)
              }
            end
          }
        }, status: :ok
      end

      def trips
        trips = filtered_trips.includes(:route, bus: :bus_operator)

        data = trips.map do |trip|
          route_stops = ordered_route_stops(trip.route)

          {
            id: trip.id,
            travel_start_date: trip.travel_start_date,
            departure_time: trip.departure_time,
            arrival_time: trip.arrival_time,
            available_seats: trip.available_seats,
            bus: {
              id: trip.bus.id,
              bus_name: trip.bus.bus_name,
              bus_type: trip.bus.bus_type,
              bus_no: trip.bus.bus_no,
              deck: trip.bus.deck,
              price: calculate_fare(trip, trip.bus.bus_operator)
            },
            operator: {
              id: trip.bus.bus_operator.id,
              company_name: trip.bus.bus_operator.company_name
            },
            route: {
              id: trip.route.id,
              source_city: trip.route.source_city,
              destination_city: trip.route.destination_city,
              distance_km: trip.route.total_distance_km
            },
            booking_context: {
              route_stops: route_stops,
              default_boarding_stop_id: route_stops.find { |stop| stop[:is_boarding_point] }&.dig(:id),
              default_drop_stop_id: route_stops.reverse.find { |stop| stop[:is_drop_point] }&.dig(:id)
            }
          }
        end

        render json: {
          message: 'Trips found',
          count: data.size,
          data: data
        }, status: :ok
      end

      def trip_seats
        trip = Trip.includes(bus: :seats).find(params[:trip_id])
        trip_seats = trip.trip_seats.includes(:seat).index_by(&:seat_id)

        data = trip.bus.seats.order(:deck, :row_number, :col_number).map do |seat|
          ts = trip_seats[seat.id]
          {
            id: seat.id,
            seatnumber: seat.seat_number,
            seattype: seat.seat_type,
            deck: seat.deck,
            rownumber: seat.row_number,
            colnumber: seat.col_number,
            status: trip_seat_status(ts),
            price: ts&.seat_price.to_f,
            tripseatid: ts&.id
          }
        end

        render json: { message: 'Trip seats fetched', data: data }, status: :ok
      end

      def create_booking
        bp = booking_params
        passengers = Array(bp[:passengers])
        user = booking_user_for(passengers)

        trip = Trip.includes(:route, :bus).find(bp[:trip_id])
        seat_numbers = Array(bp[:seat_numbers]).map(&:to_s).map(&:strip).reject(&:blank?).uniq
        return render json: { message: 'Select at least one seat' }, status: :unprocessable_entity if seat_numbers.empty?

        boarding_stop = RouteStop.find(bp[:boarding_stop_id])
        drop_stop = RouteStop.find(bp[:drop_stop_id])
        unless boarding_stop.route_id == trip.route_id && drop_stop.route_id == trip.route_id
          return render json: { message: 'Stops do not belong to trip route' }, status: :unprocessable_entity
        end
        if drop_stop.km_from_source.to_i <= boarding_stop.km_from_source.to_i
          return render json: { message: 'Drop stop must come after boarding stop' }, status: :unprocessable_entity
        end

        trip_seats = nil
        seat_by_number = nil
        if passengers.size != seat_numbers.size
          return render json: { message: 'Passenger count must match selected seats' }, status: :unprocessable_entity
        end

        booking = nil
        payment = nil
        ActiveRecord::Base.transaction do
          trip_seats = TripSeat.joins(:seat)
                               .where(trip_id: trip.id, seats: { seat_number: seat_numbers })
                               .includes(:seat)
                               .lock
                               .to_a
          seat_by_number = trip_seats.index_by { |ts| ts.seat.seat_number }

          found_numbers = seat_by_number.keys
          missing = seat_numbers - found_numbers
          if missing.any?
            raise BookingRequestError, "Seat not found: #{missing.join(', ')}"
          end

          selected_trip_seats = seat_numbers.map { |seat_number| seat_by_number.fetch(seat_number) }
          unavailable = selected_trip_seats.select { |ts| !trip_seat_available?(ts) }
          if unavailable.any?
            blocked = unavailable.map { |ts| ts.seat.seat_number }
            raise BookingRequestError, "Seats unavailable: #{blocked.join(', ')}"
          end

          total_price = selected_trip_seats.sum { |ts| ts.seat_price.to_f.round(2) }.round(2)

          booking = Booking.create!(
            user: user,
            trip: trip,
            boarding_stop: boarding_stop,
            drop_stop: drop_stop,
            total_price: total_price
          )

          seat_numbers.each_with_index do |seat_number, idx|
            ts = seat_by_number.fetch(seat_number)
            passenger_data = passengers[idx] || {}
            passenger = build_passenger!(passenger_data)
            BookingSeat.create!(
              booking: booking,
              trip_seat: ts,
              passenger: passenger,
              seat_price: ts.seat_price
            )
            ts.update!(status: 'booked', locked_by_user: nil, lock_expiry_time: nil)
          end

          available_count = trip.trip_seats.where(status: [0, 'available', nil]).count
          trip.update!(available_seats: available_count)
          payment = Payment.create!(
            booking: booking,
            amount: total_price,
            paid_at: Time.current,
            gateway_name: 'manual'
          )
        end

        booking.reload
        render json: {
          message: 'Booking created successfully',
          data: {
            id: booking.id,
            trip_id: booking.trip_id,
            status: booking.status,
            total_price: booking.total_price,
            boarding_stop: {
              id: boarding_stop.id,
              stop_name: boarding_stop.stop_name,
              city_name: boarding_stop.city_name
            },
            drop_stop: {
              id: drop_stop.id,
              stop_name: drop_stop.stop_name,
              city_name: drop_stop.city_name
            },
            seats: booking.booking_seats.includes(:trip_seat, :passenger).map do |bs|
              {
                seat_number: bs.trip_seat.seat.seat_number,
                seat_price: bs.seat_price.to_f,
                passenger: {
                  name: bs.passenger.name,
                  age: bs.passenger.age,
                  gender: display_gender(bs.passenger.gender)
                }
              }
            end,
            payment: {
              id: payment.id,
              amount: payment.amount.to_f,
              status: payment.status
            },
            created_at: booking.created_at
          }
        }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        error_message = e.message.to_s.include?(':') ? e.message.split(':', 2).last.strip : e.record.errors.full_messages.join(', ')
        render json: { message: error_message.presence || 'Unable to create booking' }, status: :unprocessable_entity
      rescue BookingRequestError => e
        render json: { message: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique
        render json: { message: 'Seats unavailable: one or more seats were just booked by another passenger' }, status: :unprocessable_entity
      end

      private



      def booking_user_for(passengers)
        return current_user if current_user.present?

        first_passenger = passengers.first || {}
        phone = (first_passenger[:phone] || first_passenger['phone']).to_s.gsub(/\D/, '')
        name = (first_passenger[:name] || first_passenger['name']).to_s.strip

        raise BookingRequestError, 'Passenger phone is required for guest booking' if phone.blank?

        existing_user = User.find_by(phone: phone)
        return existing_user if existing_user.present?

        safe_name = name.presence || 'Guest Passenger'
        timestamp = Time.current.to_i

        User.create!(
          name: safe_name,
          phone: phone,
          email: "guest_#{phone}_#{timestamp}@quickbus.local",
          password: SecureRandom.hex(8),
          role: 'passenger'
        )
      end

      def booking_params
        source_params = params[:public].is_a?(ActionController::Parameters) ? params[:public] : params
        source_params.permit(
          :trip_id,
          :boarding_stop_id,
          :drop_stop_id,
          seat_numbers: [],
          passengers: %i[name age phone gender]
        )
      end

      def build_passenger!(passenger_data)
        name = passenger_data[:name].presence || passenger_data['name'].presence || 'Passenger'
        age = (passenger_data[:age] || passenger_data['age']).to_i
        phone = passenger_data[:phone] || passenger_data['phone']
        gender = normalize_gender(passenger_data[:gender] || passenger_data['gender'])

        raise BookingRequestError, 'Passenger age must be between 1 and 119' unless age.between?(1, 119)
        raise BookingRequestError, 'Passenger gender is invalid' if gender.nil?

        passenger = Passenger.new(
          name: name,
          age: age,
          phone: phone,
          gender: gender
        )
        passenger.save!(validate: false)
        passenger
      end

      def filtered_trips
        source = params[:source].to_s.strip
        destination = params[:destination].to_s.strip
        date = params[:date].presence

        scope = Trip
          .joins(:route)
          .joins("INNER JOIN route_stops AS boarding_stops ON boarding_stops.route_id = routes.id")
          .joins("INNER JOIN route_stops AS drop_stops ON drop_stops.route_id = routes.id")
          .where('LOWER(boarding_stops.city_name) = ?', source.downcase)
          .where('LOWER(drop_stops.city_name) = ?', destination.downcase)
          .where('drop_stops.km_from_source > boarding_stops.km_from_source')
          .where(status: :scheduled)
          .where('available_seats > 0')
          .distinct

        scope = scope.where(travel_start_date: Date.parse(date)) if date.present?

        scope.order(:departure_time)
      end

      def calculate_fare(trip, operator_or_id)
        operator = operator_or_id.is_a?(BusOperator) ? operator_or_id : BusOperator.find_by(id: operator_or_id)
        operator_user_id = operator&.user_id || operator_or_id

        fare_scope = Fare.where(route_id: trip.route_id, operator_id: operator_user_id)
        fare = fare_scope.find_by(bus_type: normalize_fare_bus_type(trip.bus.bus_type)) || fare_scope.first

        return nil unless fare

        (
          fare.base_fare_per_km.to_f * trip.route.total_distance_km.to_f +
          fare.min_fare.to_f +
          fare.service_fee.to_f
        ).round(2)
      end

      def normalize_fare_bus_type(bus_type)
        return bus_type if bus_type.is_a?(Integer)

        text = bus_type.to_s.strip.downcase
        return text.to_i if text.match?(/^\d+$/)

        bus_map = {
          'ac_seater' => 0,
          'non_ac_seater' => 1,
          'ac_sleeper' => 2,
          'non_ac_sleeper' => 3
        }
        bus_map[text]
      end

      def trip_seat_status(trip_seat)
        return 0 if trip_seat.nil?
        return 0 if trip_seat.status.blank?
        return 0 if trip_seat.status.to_s == 'available'
        return 0 if trip_seat.status.to_i == 0
        1
      end

      def normalize_gender(raw_gender)
        text = raw_gender.to_s.downcase.strip
        return 0 if text == 'male' || text == 'm' || text == '0'
        return 1 if text == 'female' || text == 'f' || text == '1'
        return 2 if text == 'other' || text == 'o' || text == '2'
        nil
      end

      def display_gender(value)
        case value.to_i
        when 1 then 'female'
        when 2 then 'other'
        else 'male'
        end
      end

      def trip_seat_available?(trip_seat)
        return true if trip_seat.nil?
        status = trip_seat.status
        return true if status.blank?
        return true if status.to_s == 'available'
        return true if status.to_i == 0
        false
      end

      def ordered_route_stops(route)
        route.route_stops.order(:stop_order).map do |stop|
          {
            id: stop.id,
            city_name: stop.city_name,
            stop_name: stop.stop_name,
            stop_order: stop.stop_order,
            km_from_source: stop.km_from_source,
            scheduled_arrival_time: stop.scheduled_arrival_time,
            scheduled_departure_time: stop.scheduled_departure_time,
            is_boarding_point: stop.is_boarding_point,
            is_drop_point: stop.is_drop_point
          }
        end
      end
    end
  end
end
