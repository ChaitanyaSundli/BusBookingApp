module Api
  module V1
    class BusesController < BaseController
      skip_before_action :authenticate_user!, only: [:seat_layout]
      before_action :set_bus_operator, only: [:index, :create, :show, :update, :destroy, :seat_layout]

      def index
        result = Bus::Index.call(bus_operator: @bus_operator, current_user: current_user)
        render json: {
          message: 'Buses fetched successfully',
          data: result[:models].map { |bus| serialize_bus(bus) }
        }, status: :ok
      end

      def show
        result = Bus::Show.call(params: params, bus_operator: @bus_operator, current_user: current_user)
        if result.success?
          render json: {
            message: 'Bus fetched successfully',
            data: serialize_bus(result[:model])
          }, status: :ok
        else
          render json: {
            message: 'Failed to fetch bus',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end
       def create
        result = Bus::Create.call(params: params,current_user: current_user, bus_operator: @bus_operator)
        if result.success?
         render json: {
              message: 'Bus created successfully',
              data: serialize_bus(result[:model])
              }, status: :created
        else
         render json: {
          message: 'Failed to create bus',
          errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        result = Bus::Update.call(params: params, bus_operator: @bus_operator, current_user: current_user)
        if result.success?
          render json: {
            message: 'Bus updated successfully',
            data: serialize_bus(result[:model])
          }, status: :ok
        else
          render json: {
            message: 'Failed to update bus',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        result = Bus::Destroy.call(params: params, bus_operator: @bus_operator, current_user: current_user)
        if result.success?
          render json: { message: 'Bus deleted successfully' }, status: :ok
        else
          render json: {
            message: 'Failed to delete bus',
            errors: result[:model].errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def seat_layout
        bus = @bus_operator.buses.find(params[:id])
        layout_info = SeatLayoutGenerator.get_layout(bus.bus_type.to_s, bus.deck.to_i)
        seats_grid = build_seats_grid(bus)
        
        render json: {
          message: 'Seat layout fetched successfully',
          data: {
            bus_id: bus.id,
            bus_no: bus.bus_no,
            layout_info: layout_info,
            seats_grid: seats_grid
          }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'Bus not found' }, status: :not_found
      end

      def seat_types_info
        seat_types = SeatLayoutGenerator.available_seat_types.map do |seat_type|
          {
            type: seat_type,
            description: SeatLayoutGenerator.seat_type_description(seat_type)
          }
        end

        render json: {
          message: 'Seat types fetched successfully',
          data: seat_types
        }, status: :ok
      end

      def all_for_operator
        result = Bus::AllForOperator.call(current_user: current_user)
        if result.success?
          render json: {
            message: 'All buses fetched successfully',
            data: result[:models].map { |bus| serialize_bus(bus) }
          }, status: :ok
        else
          render json: {
            message: 'Unauthorized',
            errors: ['Only operators can view their buses']
          }, status: :forbidden
        end
      end

      private

      def set_bus_operator
        @bus_operator = BusOperator.find(params[:bus_operator_id])
      end

      def bus_params
        params.require(:bus).permit(:bus_no, :bus_name, :bus_type, :deck, :is_active)
      end

      def serialize_bus(bus)
        deck_count = (bus.deck&.to_i || 1)
        layout_info = SeatLayoutGenerator.get_layout(bus.bus_type, deck_count)
        
        {
          id:           bus.id,
          bus_no:       bus.bus_no,
          bus_name:     bus.bus_name,
          bus_type:     bus.bus_type,
          deck:         deck_count,
          total_seats:  bus.total_seats,
          seats_per_deck: layout_info[:seats_per_deck],
          is_active:    bus.is_active,
          seat_layout: {
            rows: layout_info[:rows],
            cols: layout_info[:cols],
            description: layout_info[:description]
          },
          bus_operator: {
            id:           bus.bus_operator&.id,
            company_name: bus.bus_operator&.company_name || 'N/A'
          },
          created_at: bus.created_at
        }
      end

      def build_seats_grid(bus)
        layout = SeatLayoutGenerator::SEAT_LAYOUTS[bus.bus_type&.to_sym]
        return {} unless layout
        
        rows = layout[:rows]
        decks = bus.deck&.to_i || 1

        grid = {}
        (1..decks).each do |deck_num|
          deck_name = deck_num == 1 ? 'lower' : 'upper'
          grid[deck_name] = {}

          (1..rows).each do |row|
            grid[deck_name][row] = bus.seats
              .where(row_number: row, deck: deck_name)
              .order(:col_number)
              .map { |seat| serialize_seat(seat) }
          end
        end

        grid
      end

      def serialize_seat(seat)
        {
          id: seat.id,
          seat_number: seat.seat_number,
          row: seat.row_number,
          col: seat.col_number,
          type: seat.seat_type,
          type_description: SeatLayoutGenerator.seat_type_description(seat.seat_type),
          deck: seat.deck
        }
      end
    end
  end
end