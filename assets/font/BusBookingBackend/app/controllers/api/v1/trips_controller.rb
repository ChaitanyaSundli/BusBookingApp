module Api
  module V1
    class TripsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :search,
                                                     :boarding_points, :drop_points]

      def index
        result = Trip::Index.call(current_user: current_user, params: params)
        render json: {
          message: 'Trips fetched successfully',
          data: result[:models].map { |t| serialize_trip(t) }
        }, status: :ok
      end

      def show
        result = Trip::Show.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Trip fetched successfully',
            data: serialize_trip_detail(result[:model])
          }, status: :ok
        else
          render json: { errors: result[:errors] }, status: :not_found
        end
      end

      def create
        result = Trip::Create.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Trip scheduled successfully',
            data: serialize_trip(result[:model])
          }, status: :created
        else
          render json: {
            errors: result[:model]&.errors&.full_messages || result[:errors]
          }, status: :unprocessable_entity
        end
      end

      def cancel
        result = Trip::Cancel.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Trip cancelled successfully',
            data: serialize_trip(result[:model])
          }, status: :ok
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      end

      def search
        result = Trip::Search.call(params: params)
        if result.success?
          render json: {
            message: 'Trips found',
            count: result[:models].count,
            data: result[:models].map { |t| serialize_trip(t) }
          }, status: :ok
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      end

      def boarding_points
        trip = Trip.includes(:route).find(params[:id])
        stops = trip.route.route_stops
                    .where(is_boarding_point: true)
                    .ordered

        stops = stops.where(city_name: params[:city]) if params[:city].present?

        render json: {
          message: 'Boarding points fetched',
          data: stops.map { |s| serialize_stop(s) }
        }, status: :ok
      end

      def drop_points
        trip = Trip.includes(:route).find(params[:id])
        stops = trip.route.route_stops
                    .where(is_drop_point: true)
                    .ordered

        stops = stops.where(city_name: params[:city]) if params[:city].present?

        render json: {
          message: 'Drop points fetched',
          data: stops.map { |s| serialize_stop(s) }
        }, status: :ok
      end

      private

      def serialize_trip(trip)
        {
          id:               trip.id,
          travel_start_date: trip.travel_start_date,
          departure_time:   trip.departure_time,
          arrival_time:     trip.arrival_time,
          status:           trip.status,
          available_seats:  trip.available_seats,
          bus: {
            id:       trip.bus.id,
            bus_name: trip.bus.bus_name,
            bus_type: trip.bus.bus_type,
            bus_no:   trip.bus.bus_no,
            deck:     trip.bus.deck
          },
          route: {
            id:               trip.route.id,
            source_city:      trip.route.source_city,
            destination_city: trip.route.destination_city,
            distance_km:      trip.route.total_distance_km
          },
          operator: {
            id:           trip.bus.bus_operator.id,
            company_name: trip.bus.bus_operator.company_name
          },
          created_at: trip.created_at
        }
      end

      def serialize_trip_detail(trip)
        serialize_trip(trip).merge(
          trip_seats: trip.trip_seats.map { |ts|
            {
              id:          ts.id,
              seat_number: ts.seat.seat_number,
              seat_type:   ts.seat.seat_type,
              deck:        ts.seat.deck,
              seat_price:  ts.seat_price,
              status:      ts.status
            }
          }
        )
      end

      def serialize_stop(stop)
        {
          id:                       stop.id,
          city_name:                stop.city_name,
          stop_name:                stop.stop_name,
          stop_address:             stop.stop_address,
          stop_order:               stop.stop_order,
          km_from_source:           stop.km_from_source,
          scheduled_arrival_time:   stop.scheduled_arrival_time,
          scheduled_departure_time: stop.scheduled_departure_time,
          is_boarding_point:        stop.is_boarding_point,
          is_drop_point:            stop.is_drop_point
        }
      end
    end
  end
end