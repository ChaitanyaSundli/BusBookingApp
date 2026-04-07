module Api
  module V1
    class BusOperatorsController < BaseController

      def index
        result = BusOperator::Index.call(current_user: current_user)
        render json: {
          message: 'Bus operators fetched successfully',
          data: result[:models].map { |bo| serialize_bus_operator(bo) }
        }, status: :ok
      end

      def show
        result = BusOperator::Show.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Bus operator fetched successfully',
            data: serialize_bus_operator(result[:model])
          }, status: :ok
        else
          render json: {
            message: 'Failed to fetch bus operator',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def create
        result = BusOperator::Create.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Bus operator created successfully',
            data: serialize_bus_operator(result[:model])
          }, status: :created
        else
          render json: {
            message: 'Failed to create bus operator',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        result = BusOperator::Update.call(params: params, current_user: current_user)
        if result.success?
          render json: {
            message: 'Bus operator updated successfully',
            data: serialize_bus_operator(result[:model])
          }, status: :ok
        else
          render json: {
            message: 'Failed to update bus operator',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        result = BusOperator::Destroy.call(params: params, current_user: current_user)
        if result.success?
          render json: { message: 'Bus operator deleted successfully' }, status: :ok
        else
          render json: {
            message: 'Failed to delete bus operator',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def bus_operator_params
        params.require(:bus_operator).permit(:company_name, :license_no, :contact_email)
      end

      def serialize_bus_operator(bo)
        {
          id:            bo.id,
          company_name:  bo.company_name,
          license_no:    bo.license_no,
          contact_email: bo.contact_email,
          is_verified:   bo.is_verified,
          verified_at:   bo.verified_at,
          owner: {
            id:    bo.user.id,
            name:  bo.user.name,
            email: bo.user.email
          },
          created_at: bo.created_at
        }
      end
    end
  end
end