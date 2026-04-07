module Api
  module V1
    class RoutesController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        result = Route::Index.call(current_user: current_user || guest_user)
        render json: {
          message: 'Routes fetched successfully',
          data: result[:models].map { |r| serialize_route(r) }
        }, status: :ok
      end

      def show
        result = Route::Show.call(params: params, current_user: current_user || guest_user)
        if result.success?
          render json: {
            message: 'Route fetched successfully',
            data: serialize_route_detail(result[:model])
          }, status: :ok
        else
          render json: { errors: result[:errors] }, status: :not_found
        end
      end

      def create
        result = Route::Create.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Route created successfully',
            data: serialize_route(result[:model])
          }, status: :created
        else
          render json: {
            errors: result[:model]&.errors&.full_messages || result[:errors]
          }, status: :unprocessable_entity
        end
      end

      def update
        result = Route::Update.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Route updated successfully',
            data: serialize_route(result[:model])
          }, status: :ok
        else
          render json: {
            errors: result[:model]&.errors&.full_messages || result[:errors]
          }, status: :unprocessable_entity
        end
      end

      private

      def guest_user
        OpenStruct.new(admin?: false, operator?: false, passenger?: true)
      end

      def serialize_route(route)
        {
          id:                     route.id,
          source_city:            route.source_city,
          destination_city:       route.destination_city,
          total_distance_km:      route.total_distance_km,
          estimated_duration_mins: route.estimated_duration_mins,
          is_active:              route.is_active,
          created_at:             route.created_at
        }
      end

      def serialize_route_detail(route)
        serialize_route(route).merge(
          stops: route.route_stops.ordered.map { |s| serialize_stop(s) },
          fares: route.fares.map { |f| serialize_fare(f) }
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
          halt_mins:                stop.halt_mins,
          is_boarding_point:        stop.is_boarding_point,
          is_drop_point:            stop.is_drop_point
        }
      end

      def serialize_fare(fare)
        {
          id:               fare.id,
          bus_type:         fare.bus_type,
          base_fare_per_km: fare.base_fare_per_km,
          min_fare:         fare.min_fare,
          tax_pct:          fare.tax_pct,
          service_fee:      fare.service_fee
        }
      end
    end
  end
end