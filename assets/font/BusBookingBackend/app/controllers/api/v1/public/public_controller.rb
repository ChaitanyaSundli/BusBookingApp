module Api
  module V1
    module Public
      class PublicController < ApplicationController
        skip_before_action :authenticate_user!, raise: false

        # GET /api/v1/public/stops?q=pune
        def stops
          query = params[:q].to_s.downcase.strip
          return render json: { data: [] } if query.length < 2

          stops = RouteStop
                    .joins(:route)
                    .where("LOWER(route_stops.city_name) LIKE ?", "%#{query}%")
                    .where(routes: { is_active: true })
                    .distinct
                    .limit(10)

          render json: {
            data: stops.map { |s| { cityname: s.city_name } }
          }
        end

        # GET /api/v1/public/trips
        def trips
          trips = Trip
                    .joins(:route, bus: :bus_operator)
                    .where(routes: {
                      source_city: params[:source],
                      destination_city: params[:destination]
                    })
                    .where(travel_start_date: params[:date])
                    .where(status: 0)
                    .includes(:route, bus: :bus_operator)
                    .limit(50)

          data = trips.map do |t|
            fare = t.bus.seats.first&.trip_seats&.find_by(trip_id: t.id)&.seat_price ||
                   calculate_fare(t) || 0

            {
              id: t.id,
              travelstartdate: t.travel_start_date,
              departuretime: t.departure_time&.strftime("%H:%M"),
              arrivaltime: t.arrival_time&.strftime("%H:%M"),
              status: t.status,
              availableseats: t.available_seats.to_i,

              bus: {
                id: t.bus.id,
                busname: t.bus.bus_name,
                bustype: t.bus.bus_type,
                busno: t.bus.bus_no,
                deck: t.bus.deck,
                totalseats: t.bus.total_seats,
                price: fare
              },

              operator: {
                id: t.bus.bus_operator.id,
                companyname: t.bus.bus_operator.company_name
              },

              route: {
                id: t.route.id,
                sourcecity: t.route.source_city,
                destinationcity: t.route.destination_city,
                distancekm: t.route.total_distance_km
              }
            }
          end

          render json: { message: "ok", count: data.size, data: data }
        end

        # GET /api/v1/public/trips/:trip_id/seats
        def trip_seats
          trip = Trip.find(params[:trip_id])

          seats = Seat.where(bus_id: trip.bus_id).includes(:trip_seats)

          data = seats.map do |s|
            ts = s.trip_seats.find { |x| x.trip_id == trip.id }

            {
              id: s.id,
              seatnumber: s.seat_number,
              seattype: s.seat_type,
              deck: s.deck,
              rownumber: s.row_number,
              colnumber: s.col_number,
              status: ts&.status || 0,
              price: ts&.seat_price || calculate_fare(trip),
              tripseatid: ts&.id
            }
          end

          render json: { data: data }
        end

        # GET /api/v1/public/trips/:trip_id/boarding_points
        def boarding_points
          trip = Trip.find(params[:trip_id])

          stops = RouteStop
                    .where(route_id: trip.route_id, is_boarding_point: true)
                    .order(:stop_order)

          render json: {
            data: stops.map do |s|
              {
                id: s.id,
                stopname: s.stop_name,
                cityname: s.city_name,
                address: s.stop_address,
                time: s.scheduled_departure_time&.strftime("%I:%M %p")
              }
            end
          }
        end

        # GET /api/v1/public/trips/:trip_id/dropping_points
        def dropping_points
          trip = Trip.find(params[:trip_id])

          stops = RouteStop
                    .where(route_id: trip.route_id, is_drop_point: true)
                    .order(:stop_order)

          render json: {
            data: stops.map do |s|
              {
                id: s.id,
                stopname: s.stop_name,
                cityname: s.city_name,
                address: s.stop_address,
                time: s.scheduled_arrival_time&.strftime("%I:%M %p")
              }
            end
          }
        end

        # GET /api/v1/public/operators
        def operators
          ops = BusOperator.where(is_verified: true).limit(10)

          render json: {
            data: ops.map { |o| { id: o.id, companyname: o.company_name } }
          }
        end

        private

        def calculate_fare(trip)
          fare = Fare.find_by(route_id: trip.route_id)
          return 0 unless fare && trip.route

          dist = trip.route.total_distance_km.to_f
          [(fare.base_fare_per_km.to_f * dist) + fare.service_fee.to_f,
           fare.min_fare.to_f].max
        end
      end
    end
  end
end