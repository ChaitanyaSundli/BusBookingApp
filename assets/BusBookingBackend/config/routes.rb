Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post 'passenger/register', to: 'passenger_registrations#create'
        post 'operator/register', to: 'operator_registrations#create'
        post 'sign_in', to: 'sessions#create'
        delete 'sign_out', to: 'sessions#destroy'
      end

      get 'buses/all', to: 'buses#all_for_operator'

      resources :bus_operators, only: %i[index create show update destroy] do
        resources :buses, only: %i[index create show update destroy] do
          member do
            get :seat_layout
          end
          collection do
            get :seat_types_info
          end
        end
      end

      resources :routes, only: %i[index create show update] do
        resources :route_stops, only: %i[index create]
        resources :fares, only: %i[index create]
      end

      resources :trips, only: %i[index create show] do
        member do
          patch :cancel
          get :boarding_points
          get :drop_points
        end
        collection do
          get :search
        end
      end

      scope :public, controller: :public do
        get 'stops', action: :stops
        get 'operators', action: :operators
        get 'operators/all', action: :all_operators
        get 'operators/:operator_id', action: :operator_overview
        get 'operator_trips', action: :operator_trips
        get 'trips', action: :trips
        get 'trips/:trip_id/seats', action: :trip_seats
        post 'bookings', action: :create_booking
      end
    end
  end
end
