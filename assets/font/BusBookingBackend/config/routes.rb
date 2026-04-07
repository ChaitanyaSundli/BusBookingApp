Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post   'passenger/register', to: 'passenger_registrations#create'
        post   'operator/register',  to: 'operator_registrations#create'
        post   'sign_in',            to: 'sessions#create'
        delete 'sign_out',           to: 'sessions#destroy'
      end

      get 'buses/all', to: 'buses#all_for_operator'

      resources :bus_operators, only: [:index, :create, :show, :update, :destroy] do
        resources :buses, only: [:index, :create, :show, :update, :destroy] do
          member do
            get :seat_layout
          end
          collection do
            get :seat_types_info
          end
        end
      end

      resources :routes, only: [:index, :create, :show, :update] do
        resources :route_stops, only: [:index, :create]
        resources :fares,       only: [:index, :create]
      end

      resources :trips, only: [:index, :create, :show] do
        member do
          patch :cancel
          get   :boarding_points
          get   :drop_points
        end
        collection do
          get :search
        end
        resources :reviews, only: [:create]
      end

      resources :bookings, only: [:create, :index, :show] do
        member do
          patch :cancel
        end
      end

      resources :payments, only: [:create]
    end
  end
end
