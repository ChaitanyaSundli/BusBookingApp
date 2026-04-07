module Api
  module V1
    class FaresController < BaseController
      skip_before_action :authenticate_user!, only: [:index]

      def index
        result = Fare::Index.call(params: params, current_user: current_user)
        render json: {
          message: 'Fares fetched successfully',
          data: result[:models].map { |f| serialize_fare(f) }
        }, status: :ok
      end

      def create
        result = Fare::Create.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Fare created successfully',
            data: serialize_fare(result[:model])
          }, status: :created
        else
          render json: {
            errors: result[:model]&.errors&.full_messages || result[:errors]
          }, status: :unprocessable_entity
        end
      end

      private

      def serialize_fare(fare)
        {
          id:               fare.id,
          route_id:         fare.route_id,
          bus_type:         fare.bus_type,
          base_fare_per_km: fare.base_fare_per_km,
          min_fare:         fare.min_fare,
          tax_pct:          fare.tax_pct,
          service_fee:      fare.service_fee,
          operator_id:      fare.operator_id,
          created_at:       fare.created_at
        }
      end
    end
  end
end