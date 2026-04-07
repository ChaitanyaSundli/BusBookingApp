class Route < ApplicationRecord
  has_many :trips, dependent: :destroy
  has_many :route_stops, ->{order(:stop_order)}, dependent: :destroy
  has_many :fares, dependent: :destroy

  validates :source_city, :destination_city, presence: true
end
