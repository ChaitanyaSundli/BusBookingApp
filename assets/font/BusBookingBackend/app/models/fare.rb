class Fare < ApplicationRecord
  belongs_to :route
  belongs_to :operator, class_name: 'User', foreign_key: :operator_id

  BUS_TYPES = %w[ac_seater non_ac_seater ac_sleeper non_ac_sleeper].freeze

  validates :bus_type, :base_fare_per_km, :min_fare, presence: true
  validates :bus_type, inclusion: { in: BUS_TYPES }
  validates :bus_type, uniqueness: { scope: [:route_id, :operator_id] }
end